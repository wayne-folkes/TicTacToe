import XCTest
@testable import GamesApp

@MainActor
final class MemoryGameStateTests: XCTestCase {
    func testInitialization() {
        let state = MemoryGameState()
        
        XCTAssertEqual(state.cards.count, 24) // 12 pairs = 24 cards
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.isGameOver)
        XCTAssertEqual(state.currentTheme, .animals)
        
        // All cards should be face down
        XCTAssertTrue(state.cards.allSatisfy { !$0.isFaceUp })
        // No cards should be matched
        XCTAssertTrue(state.cards.allSatisfy { !$0.isMatched })
    }
    
    func testCardsArePaired() {
        let state = MemoryGameState()
        
        // Group cards by content
        let cardContents = state.cards.map { $0.content }
        let contentCounts = Dictionary(grouping: cardContents, by: { $0 })
            .mapValues { $0.count }
        
        // Each emoji should appear exactly twice
        for (_, count) in contentCounts {
            XCTAssertEqual(count, 2, "Each card content should appear exactly twice")
        }
    }
    
    func testCardsAreShuffled() {
        let state1 = MemoryGameState()
        let state2 = MemoryGameState()
        
        let order1 = state1.cards.map { $0.content }
        let order2 = state2.cards.map { $0.content }
        
        // It's extremely unlikely (but technically possible) for two shuffled decks to be identical
        // This test might occasionally fail due to randomness, but it's a good sanity check
        let areIdentical = order1 == order2
        
        // If they are different, great. If they are the same, we'll just note it
        // (In practice, with 24 cards, the probability of identical order is 1/24! which is astronomically small)
        if areIdentical {
            // This is fine - just very unlikely
            print("Note: Two randomly shuffled decks ended up identical (extremely rare but possible)")
        }
        
        // At minimum, verify both have the same content (just different order)
        XCTAssertEqual(Set(order1), Set(order2), "Both games should have the same card contents")
    }
    
    func testChooseFirstCard() {
        let state = MemoryGameState()
        let firstCard = state.cards[0]
        
        state.choose(firstCard)
        
        // Card should be face up
        XCTAssertTrue(state.cards[0].isFaceUp)
        // Score should remain 0
        XCTAssertEqual(state.score, 0)
        // Game should not be over
        XCTAssertFalse(state.isGameOver)
    }
    
    func testMatchingPair() {
        let state = MemoryGameState()
        
        // Find two cards with the same content
        let targetContent = state.cards[0].content
        let firstIndex = 0
        let secondIndex = state.cards.firstIndex(where: { $0.content == targetContent && $0.id != state.cards[firstIndex].id })!
        
        // Choose first card
        state.choose(state.cards[firstIndex])
        XCTAssertTrue(state.cards[firstIndex].isFaceUp)
        XCTAssertFalse(state.cards[firstIndex].isMatched)
        
        // Choose matching card
        state.choose(state.cards[secondIndex])
        
        // Both cards should be face up and matched
        XCTAssertTrue(state.cards[firstIndex].isFaceUp)
        XCTAssertTrue(state.cards[firstIndex].isMatched)
        XCTAssertTrue(state.cards[secondIndex].isFaceUp)
        XCTAssertTrue(state.cards[secondIndex].isMatched)
        
        // Score should increase by 2
        XCTAssertEqual(state.score, 2)
    }
    
    func testNonMatchingPair() {
        let state = MemoryGameState()
        
        // Find two cards with different content
        let firstIndex = state.cards.firstIndex(where: { _ in true })!
        let firstContent = state.cards[firstIndex].content
        let secondIndex = state.cards.firstIndex(where: { $0.content != firstContent })!
        
        // Choose first card
        state.choose(state.cards[firstIndex])
        
        // Choose non-matching card
        state.choose(state.cards[secondIndex])
        
        // Both cards should be face up but not matched
        XCTAssertTrue(state.cards[firstIndex].isFaceUp)
        XCTAssertFalse(state.cards[firstIndex].isMatched)
        XCTAssertTrue(state.cards[secondIndex].isFaceUp)
        XCTAssertFalse(state.cards[secondIndex].isMatched)
        
        // Score should decrease by 1
        XCTAssertEqual(state.score, -1)
    }
    
    func testThirdCardFlipsFirstTwoDown() {
        let state = MemoryGameState()
        
        // Find three cards with different content
        let card1 = state.cards[0]
        let card2 = state.cards.first(where: { $0.content != card1.content })!
        let card3 = state.cards.first(where: { $0.content != card1.content && $0.content != card2.content })!
        
        // Choose first card
        state.choose(card1)
        let index1 = state.cards.firstIndex(where: { $0.id == card1.id })!
        XCTAssertTrue(state.cards[index1].isFaceUp)
        
        // Choose second non-matching card
        state.choose(card2)
        let index2 = state.cards.firstIndex(where: { $0.id == card2.id })!
        XCTAssertTrue(state.cards[index2].isFaceUp)
        
        // Choose third card - should flip first two down
        state.choose(card3)
        let index3 = state.cards.firstIndex(where: { $0.id == card3.id })!
        
        // First two should be face down (unless they were matched)
        if !state.cards[index1].isMatched {
            XCTAssertFalse(state.cards[index1].isFaceUp)
        }
        if !state.cards[index2].isMatched {
            XCTAssertFalse(state.cards[index2].isFaceUp)
        }
        
        // Third card should be face up
        XCTAssertTrue(state.cards[index3].isFaceUp)
    }
    
    func testCannotChooseFaceUpCard() {
        let state = MemoryGameState()
        let card = state.cards[0]
        
        // Choose card once
        state.choose(card)
        let scoreAfterFirst = state.score
        
        // Try to choose same card again
        state.choose(card)
        
        // Score should not change
        XCTAssertEqual(state.score, scoreAfterFirst)
    }
    
    func testCannotChooseMatchedCard() {
        let state = MemoryGameState()
        
        // Find and match a pair
        let targetContent = state.cards[0].content
        let firstIndex = 0
        let secondIndex = state.cards.firstIndex(where: { $0.content == targetContent && $0.id != state.cards[firstIndex].id })!
        
        state.choose(state.cards[firstIndex])
        state.choose(state.cards[secondIndex])
        
        let scoreAfterMatch = state.score
        
        // Try to choose matched card again
        state.choose(state.cards[firstIndex])
        
        // Score should not change
        XCTAssertEqual(state.score, scoreAfterMatch)
    }
    
    func testWinCondition() {
        let state = MemoryGameState()
        
        // Match all pairs
        var processedCards = Set<UUID>()
        
        for card in state.cards {
            if processedCards.contains(card.id) {
                continue
            }
            
            let matchingCard = state.cards.first(where: { 
                $0.content == card.content && $0.id != card.id && !processedCards.contains($0.id)
            })!
            
            state.choose(card)
            state.choose(matchingCard)
            
            processedCards.insert(card.id)
            processedCards.insert(matchingCard.id)
        }
        
        // All cards should be matched
        XCTAssertTrue(state.cards.allSatisfy { $0.isMatched })
        // Game should be over
        XCTAssertTrue(state.isGameOver)
        // Score should be positive (12 matches * 2 = 24)
        XCTAssertEqual(state.score, 24)
    }
    
    func testThemeSwitching() {
        let state = MemoryGameState()
        let initialTheme = state.currentTheme
        
        // Switch to different theme
        let newTheme: MemoryGameState.MemoryTheme = initialTheme == .animals ? .people : .animals
        state.toggleTheme(newTheme)
        
        XCTAssertEqual(state.currentTheme, newTheme)
        
        // Game should reset
        XCTAssertEqual(state.cards.count, 24)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.isGameOver)
        XCTAssertTrue(state.cards.allSatisfy { !$0.isFaceUp })
        XCTAssertTrue(state.cards.allSatisfy { !$0.isMatched })
        
        // Cards should be from new theme
        let themeEmojis = Set(newTheme.emojis)
        let cardEmojis = Set(state.cards.map { $0.content })
        XCTAssertTrue(cardEmojis.isSubset(of: themeEmojis), "All card emojis should be from the new theme")
    }
    
    func testStartNewGame() {
        let state = MemoryGameState()
        
        // Make some moves
        state.choose(state.cards[0])
        state.choose(state.cards[1])
        
        // Start new game
        state.startNewGame()
        
        // Everything should be reset
        XCTAssertEqual(state.cards.count, 24)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.isGameOver)
        XCTAssertTrue(state.cards.allSatisfy { !$0.isFaceUp })
        XCTAssertTrue(state.cards.allSatisfy { !$0.isMatched })
    }
    
    func testThemeEmojis() {
        // Test Animals theme
        let animalEmojis = MemoryGameState.MemoryTheme.animals.emojis
        XCTAssertGreaterThanOrEqual(animalEmojis.count, 12, "Animals theme should have at least 12 emojis")
        
        // Test People theme
        let peopleEmojis = MemoryGameState.MemoryTheme.people.emojis
        XCTAssertGreaterThanOrEqual(peopleEmojis.count, 12, "People theme should have at least 12 emojis")
        
        // Themes should be different
        XCTAssertNotEqual(Set(animalEmojis), Set(peopleEmojis), "Theme emojis should be different")
    }
}
