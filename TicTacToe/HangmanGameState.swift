import SwiftUI
import Combine

/// Word categories available in the Hangman game.
enum WordCategory: String, CaseIterable, Identifiable {
    case animals = "Animals"
    case food = "Food"
    case sports = "Sports"
    case colors = "Colors"
    case countries = "Countries"
    
    var id: String { self.rawValue }
}

/// Game logic and state management for Hangman with stick figure drawing.
///
/// This class implements the classic word-guessing game where players guess letters
/// to reveal a hidden word before the stick figure is complete. Features multiple
/// word categories and tracks used words to avoid repetition.
///
/// ## Features
/// - **5 Word Categories**: Animals, Food, Sports, Colors, Countries
/// - **8 Wrong Guesses**: More forgiving than traditional 6-guess limit
/// - **Progressive Drawing**: Gallows, head, body, left arm, right arm, left leg, right leg, sad face
/// - **Word Tracking**: Remembers correctly-guessed words per category (persisted to UserDefaults)
/// - **Smart Word Selection**: Avoids repeating words until all words in category are used
/// - **Scoring**: Points based on remaining attempts when word is guessed
/// - **All Words ≤ 8 Letters**: Fits comfortably on screen
///
/// ## Gameplay
/// 1. Player selects a letter from A-Z keyboard
/// 2. If correct: letter revealed in word
/// 3. If wrong: stick figure part added, score decreases
/// 4. Win: guess all letters before 8 wrong guesses
/// 5. Lose: stick figure complete (8 parts drawn)
///
/// ## Usage
/// ```swift
/// @StateObject private var gameState = HangmanGameState()
///
/// // Change category
/// gameState.setCategory(.food)
///
/// // Player guesses a letter
/// gameState.guessLetter("A")
///
/// // Check display word (with underscores)
/// print(gameState.displayWord) // "_ A _"
///
/// // Check game state
/// if gameState.hasWon {
///     print("Word guessed! Score: \(gameState.score)")
/// }
/// ```
///
/// - Important: Must be accessed from the main actor/thread
@MainActor
class HangmanGameState: ObservableObject {
    /// The word the player is trying to guess (uppercase)
    @Published var currentWord: String = ""
    
    /// Set of letters the player has guessed (both correct and wrong)
    @Published var guessedLetters: Set<Character> = []
    
    /// Number of incorrect guesses (0-8)
    @Published var wrongGuesses: Int = 0
    
    /// Current score (decreases with wrong guesses)
    @Published var score: Int = 0
    
    /// Total games won in this session
    @Published var gamesWon: Int = 0
    
    /// Total games lost in this session
    @Published var gamesLost: Int = 0
    
    /// Whether the current game has ended (win or lose)
    @Published var isGameOver: Bool = false
    
    /// Whether the player won (guessed the word)
    @Published var hasWon: Bool = false
    
    /// Currently selected word category
    @Published var selectedCategory: WordCategory = .animals
    
    /// Maximum wrong guesses before game over (8 = complete stick figure)
    let maxWrongGuesses = 8
    
    /// Tracks which words have been correctly guessed per category (persisted)
    private var usedWords: [WordCategory: Set<String>] = [:]
    private let usedWordsDefaultsKey = "HangmanUsedWords"
    
    /// Word bank for all categories (all words ≤ 8 letters).
    /// Contains 18-24 words per category for variety.
    private let wordBank: [WordCategory: [String]] = [
        .animals: [
            "CAT", "DOG", "BEAR", "LION", "TIGER", "ELEPHANT",
            "GIRAFFE", "MONKEY", "ZEBRA", "RABBIT", "HORSE", "BIRD",
            "FISH", "SHARK", "WHALE", "DOLPHIN", "EAGLE", "PENGUIN",
            "KOALA", "PANDA", "FOX", "WOLF", "DEER", "MOOSE"
        ],
        .food: [
            "PIZZA", "BURGER", "PASTA", "TACO", "RICE", "BREAD",
            "CHEESE", "APPLE", "BANANA", "ORANGE", "GRAPE", "BERRY",
            "SALAD", "SOUP", "STEAK", "CHICKEN", "FISH", "SHRIMP",
            "COOKIE", "CAKE", "PIE", "CANDY", "HONEY", "BUTTER"
        ],
        .sports: [
            "SOCCER", "TENNIS", "HOCKEY", "GOLF", "RUGBY", "CRICKET",
            "BOXING", "SKIING", "SURFING", "RUNNING", "SWIMMING", "CYCLING",
            "BASEBALL", "FOOTBALL", "BOWLING", "FENCING", "ARCHERY", "SKATING"
        ],
        .colors: [
            "RED", "BLUE", "GREEN", "YELLOW", "ORANGE", "PURPLE",
            "PINK", "BROWN", "BLACK", "WHITE", "GRAY", "SILVER",
            "GOLD", "BRONZE", "VIOLET", "INDIGO", "CYAN", "MAGENTA"
        ],
        .countries: [
            "USA", "CANADA", "MEXICO", "BRAZIL", "FRANCE", "SPAIN",
            "ITALY", "GREECE", "EGYPT", "CHINA", "JAPAN", "INDIA",
            "RUSSIA", "POLAND", "TURKEY", "IRELAND", "SWEDEN", "NORWAY"
        ]
    ]
    
    /// Initialize a new Hangman game with default category (Animals).
    /// Loads previously-guessed words from UserDefaults and starts a new game.
    init() {
        loadPersistedUsedWords()
        startNewGame()
    }
    
    /// Change the word category and start a new game.
    ///
    /// - Parameter category: The new category to use
    func setCategory(_ category: WordCategory) {
        selectedCategory = category
        startNewGame()
    }
    
    /// Start a new game with a fresh word from the current category.
    ///
    /// Selects a random word that hasn't been correctly guessed yet. If all words
    /// in the category have been used, resets the used words list to allow repeats.
    func startNewGame() {
        guessedLetters = []
        wrongGuesses = 0
        isGameOver = false
        hasWon = false
        
        // Select random word, avoiding correctly-guessed words until exhausted
        if let words = wordBank[selectedCategory], !words.isEmpty {
            let used = usedWords[selectedCategory] ?? []
            let available = words.filter { !used.contains($0) }
            let pool = available.isEmpty ? words : available
            if available.isEmpty {
                // All words exhausted; reset the used list for this category
                usedWords[selectedCategory] = []
                persistUsedWords()
            }
            currentWord = pool.randomElement() ?? "CAT"
        } else {
            currentWord = "CAT"
        }
    }
    
    /// Process a letter guess and update game state accordingly.
    ///
    /// Validates the guess (not already guessed, game not over), adds the letter
    /// to guessed set, and checks for win/lose conditions. Plays haptic feedback
    /// and sound effects based on the outcome.
    ///
    /// - Parameter letter: The letter to guess (A-Z, uppercase)
    func guessLetter(_ letter: Character) {
        // Don't allow guesses if game is over or letter already guessed
        guard !isGameOver, !guessedLetters.contains(letter) else { return }
        
        // Trigger haptic feedback for valid guess
        HapticManager.shared.impact(style: .light)
        
        guessedLetters.insert(letter)
        
        // Check if letter is in the word
        if !currentWord.contains(letter) {
            wrongGuesses += 1
            
            // Check for loss
            if wrongGuesses >= maxWrongGuesses {
                isGameOver = true
                hasWon = false
                gamesLost += 1
                GameStatistics.shared.recordHangmanGame(score: score, won: false)
            }
        } else {
            SoundManager.shared.play(.success)
            // Check for win (all letters guessed)
            if isWordComplete() {
                isGameOver = true
                hasWon = true
                gamesWon += 1
                score += 10
                GameStatistics.shared.recordHangmanGame(score: score, won: true)
                // Store the word as used only when guessed correctly
                usedWords[selectedCategory, default: []].insert(currentWord)
                persistUsedWords()
            }
        }
    }
    
    func isWordComplete() -> Bool {
        for letter in currentWord {
            if !guessedLetters.contains(letter) {
                return false
            }
        }
        return true
    }
    
    func getDisplayWord() -> String {
        var display = ""
        for letter in currentWord {
            if guessedLetters.contains(letter) {
                display += String(letter)
            } else {
                display += "_"
            }
            display += " "
        }
        return display.trimmingCharacters(in: .whitespaces)
    }
    
    private func persistUsedWords() {
        var dict: [String: [String]] = [:]
        for (category, set) in usedWords {
            dict[category.rawValue] = Array(set)
        }
        UserDefaults.standard.set(dict, forKey: usedWordsDefaultsKey)
    }

    private func loadPersistedUsedWords() {
        guard let dict = UserDefaults.standard.dictionary(forKey: usedWordsDefaultsKey) as? [String: [String]] else { return }
        var result: [WordCategory: Set<String>] = [:]
        for (key, values) in dict {
            if let category = WordCategory(rawValue: key) {
                result[category] = Set(values)
            }
        }
        usedWords = result
    }
    
    func resetStats() {
        score = 0
        gamesWon = 0
        gamesLost = 0
        startNewGame()
    }
}
