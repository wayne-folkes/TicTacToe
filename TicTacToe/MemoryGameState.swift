import SwiftUI
import Combine

/// Represents a single card in the Memory game.
///
/// Each card has a unique ID, emoji content, and two states:
/// - `isFaceUp`: Whether the card is currently visible
/// - `isMatched`: Whether this card has been successfully matched with its pair
struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

/// Game logic and state management for the Memory card-matching game.
///
/// This class implements a 4x6 grid (24 cards, 12 pairs) memory matching game with
/// multiple themes. Players flip two cards at a time, earning points for matches
/// and losing points for mismatches.
///
/// ## Features
/// - **Two Themes**: Animals (🐶🐱) and People (👮👷) emojis
/// - **Scoring**: +2 for matches, -1 for mismatches
/// - **Static Arrays**: Emoji lists cached as static constants for performance
/// - **Win Detection**: Automatically detects when all pairs are matched
/// - **Statistics**: Records final score and completion to GameStatistics
///
/// ## Gameplay
/// 1. Player flips first card (face up)
/// 2. Player flips second card
/// 3. If match: cards stay face up, +2 points
/// 4. If no match: cards flip back down, -1 point
/// 5. Continue until all pairs matched
///
/// ## Usage
/// ```swift
/// @StateObject private var gameState = MemoryGameState()
///
/// // Start game with selected theme
/// gameState.toggleTheme(.people)
///
/// // Player taps a card
/// gameState.choose(card)
///
/// // Check if won
/// if gameState.isGameOver {
///     print("All pairs matched! Score: \(gameState.score)")
/// }
/// ```
///
/// - Important: Must be accessed from the main actor/thread
@MainActor
class MemoryGameState: ObservableObject {
    /// Array of all 24 cards in the game
    @Published var cards: [MemoryCard] = []
    
    /// Current score (increases with matches, decreases with mismatches)
    @Published var score: Int = 0
    
    /// Whether all pairs have been matched
    @Published var isGameOver: Bool = false
    
    /// Currently selected emoji theme
    @Published var currentTheme: MemoryTheme = .animals
    
    /// Index of the single face-up card (nil if 0 or 2 cards are face up)
    private var indexOfTheOneAndOnlyFaceUpCard: Int?
    
    /// Available themes for the Memory game.
    enum MemoryTheme: String, CaseIterable, Identifiable {
        case animals = "Animals"
        case people = "People"
        
        var id: String { self.rawValue }
        
        /// Pre-allocated array of animal emojis (performance optimization).
        /// Static storage avoids repeated allocations on theme access.
        static let animalEmojis: [String] = [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐯", "🐨", 
            "🐻", "🐼", "🐻‍❄️", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🦅"
        ]
        
        /// Pre-allocated array of people emojis (performance optimization).
        static let peopleEmojis: [String] = [
            "👮", "👷", "💂", "🕵️", "🧑‍⚕️", "🧑‍🌾", "🧑‍🍳", "🧑‍🎓", 
            "🧑‍🎤", "🧑‍🏫", "🧑‍🏭", "🧑‍💻", "🧑‍💼", "🧑‍🔧", "🧑‍🔬", "🧑‍🎨", "🧑‍🚒", "🧑‍✈️"
        ]
        
        /// Returns the emoji array for the current theme.
        var emojis: [String] {
            switch self {
            case .animals:
                return Self.animalEmojis
            case .people:
                return Self.peopleEmojis
            }
        }
    }
    
    /// Initialize a new Memory game with the default theme (Animals).
    init() {
        startNewGame()
    }
    
    /// Change the theme and start a new game.
    ///
    /// Includes optimization to avoid redundant work if the same theme is selected again.
    ///
    /// - Parameter theme: The new theme to use (Animals or People)
    func toggleTheme(_ theme: MemoryTheme) {
        // Guard against redundant theme changes
        guard theme != currentTheme else { return }
        currentTheme = theme
        startNewGame()
    }
    
    /// Reset the game with a fresh deck of shuffled cards.
    ///
    /// Creates 24 cards (12 pairs) from the current theme's emojis and shuffles them.
    /// Resets score, game over state, and face-up card tracking.
    func startNewGame() {
        var newCards: [MemoryCard] = []
        // Take 12 unique emojis and create 2 cards for each (12 pairs = 24 cards)
        let selectedEmojis = currentTheme.emojis.prefix(12) 
        
        for emoji in selectedEmojis {
            newCards.append(MemoryCard(content: emoji))
            newCards.append(MemoryCard(content: emoji))
        }
        
        cards = newCards.shuffled()
        score = 0
        isGameOver = false
        indexOfTheOneAndOnlyFaceUpCard = nil
    }
    
    /// Handle a card flip when the player taps a card.
    ///
    /// This method implements the core game logic:
    /// 1. Ignore taps on already face-up or matched cards
    /// 2. If this is the first card: flip it face up
    /// 3. If this is the second card: check for match
    ///    - Match: keep both cards face up, award points, play success sound
    ///    - No match: lose a point (cards flip back automatically on next turn)
    /// 4. Check if game is won (all pairs matched)
    ///
    /// - Parameter card: The card that was tapped
    func choose(_ card: MemoryCard) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    score += 2
                    SoundManager.shared.play(.success)
                } else {
                    score -= 1
                }
                cards[chosenIndex].isFaceUp = true
                indexOfTheOneAndOnlyFaceUpCard = nil
            } else {
                for index in cards.indices {
                    if cards[index].isFaceUp && !cards[index].isMatched {
                         cards[index].isFaceUp = false
                    }
                }
                cards[chosenIndex].isFaceUp = true
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
            
            checkForWin()
        }
    }
    
    /// Check if all pairs have been matched and record the game if so.
    ///
    /// Called after each pair attempt. Updates `isGameOver` and records
    /// statistics when the player completes the game.
    private func checkForWin() {
        if cards.allSatisfy({ $0.isMatched }) {
            isGameOver = true
            GameStatistics.shared.recordMemoryGame(score: score, won: true)
        }
    }
}
