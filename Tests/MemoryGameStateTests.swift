import XCTest
@testable import GamesApp

@MainActor
final class MemoryGameStateTests: XCTestCase {
    func testInitialization() {
        let state = MemoryGameState()
        
        XCTAssertEqual(state.cards.count, 20) // 10 pairs = 20 cards
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
        
        // Verify cards are shuffled by checking they're not in sequential pairs
        var consecutivePairs = 0
        for i in 0..<state.cards.count - 1 {
            if state.cards[i].content == state.cards[i + 1].content {
                consecutivePairs += 1
            }
        }
        // With proper shuffling, it's very unlikely to have many consecutive pairs
        // (10 pairs in random order should have ~1 consecutive pair on average)
        XCTAssertLessThan(consecutivePairs, 5, "Cards should be shuffled, not in sequential pairs")
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
    
    func testThirdCardFlipsFirstTwoDown() async {
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
        
        // Cards should still be face up (mismatch processing with 1.5s delay)
        XCTAssertTrue(state.isProcessingMismatch, "Should be processing mismatch")
        
        // Third card tap should be blocked during processing
        state.choose(card3)
        let index3 = state.cards.firstIndex(where: { $0.id == card3.id })!
        XCTAssertFalse(state.cards[index3].isFaceUp, "Third card should not flip during processing")
        
        // Wait for the 1.5 second delay
        try? await Task.sleep(for: .seconds(1.6))
        
        // After delay, first two cards should flip back
        XCTAssertFalse(state.cards[index1].isFaceUp)
        XCTAssertFalse(state.cards[index2].isFaceUp)
        XCTAssertFalse(state.isProcessingMismatch, "Should no longer be processing")
        
        // Now third card should be selectable
        state.choose(card3)
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
        // Score should be positive (10 matches * 2 = 20)
        XCTAssertEqual(state.score, 20)
    }
    
    func testThemeSwitching() {
        let state = MemoryGameState()
        let initialTheme = state.currentTheme
        
        // Switch to different theme
        let newTheme: MemoryGameState.MemoryTheme = initialTheme == .animals ? .people : .animals
        state.toggleTheme(newTheme)
        
        XCTAssertEqual(state.currentTheme, newTheme)
        
        // Game should reset
        XCTAssertEqual(state.cards.count, 20)
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
        XCTAssertEqual(state.cards.count, 20)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.isGameOver)
        XCTAssertTrue(state.cards.allSatisfy { !$0.isFaceUp })
        XCTAssertTrue(state.cards.allSatisfy { !$0.isMatched })
    }
    
    func testThemeEmojis() {
        // Test Animals theme
        let animalEmojis = MemoryGameState.MemoryTheme.animals.emojis
        XCTAssertGreaterThanOrEqual(animalEmojis.count, 10, "Animals theme should have at least 10 emojis")
        
        // Test People theme
        let peopleEmojis = MemoryGameState.MemoryTheme.people.emojis
        XCTAssertGreaterThanOrEqual(peopleEmojis.count, 10, "People theme should have at least 10 emojis")
        
        // Themes should be different
        XCTAssertNotEqual(Set(animalEmojis), Set(peopleEmojis), "Theme emojis should be different")
    }
    
    func testMismatchFlipsCardsBackAfterDelay() async {
        let state = MemoryGameState()
        
        // Find two cards with different content
        let firstContent = state.cards[0].content
        let firstIndex = 0
        let secondIndex = state.cards.firstIndex(where: { $0.content != firstContent })!
        
        // Choose first card
        state.choose(state.cards[firstIndex])
        XCTAssertTrue(state.cards[firstIndex].isFaceUp)
        
        // Choose non-matching card
        state.choose(state.cards[secondIndex])
        
        // Both cards should be face up immediately after mismatch
        XCTAssertTrue(state.cards[firstIndex].isFaceUp)
        XCTAssertTrue(state.cards[secondIndex].isFaceUp)
        XCTAssertTrue(state.isProcessingMismatch, "Should be processing mismatch")
        
        // Verify mismatch cards are tracked
        XCTAssertTrue(state.mismatchedCardIds.contains(state.cards[firstIndex].id))
        XCTAssertTrue(state.mismatchedCardIds.contains(state.cards[secondIndex].id))
        
        // Wait for the 1.5 second delay
        try? await Task.sleep(for: .seconds(1.6))
        
        // After delay, cards should flip back
        XCTAssertFalse(state.cards[firstIndex].isFaceUp, "First card should be flipped back")
        XCTAssertFalse(state.cards[secondIndex].isFaceUp, "Second card should be flipped back")
        XCTAssertFalse(state.isProcessingMismatch, "Should no longer be processing")
        XCTAssertTrue(state.mismatchedCardIds.isEmpty, "Mismatch IDs should be cleared")
    }
    
    func testCardSelectionsBlockedDuringMismatchProcessing() async {
        let state = MemoryGameState()
        
        // Find three different cards
        let card1 = state.cards[0]
        let card2 = state.cards.first(where: { $0.content != card1.content })!
        let card3 = state.cards.first(where: { $0.content != card1.content && $0.content != card2.content })!
        
        // Choose first card
        state.choose(card1)
        let index1 = state.cards.firstIndex(where: { $0.id == card1.id })!
        XCTAssertTrue(state.cards[index1].isFaceUp)
        
        // Choose second non-matching card (triggers mismatch)
        state.choose(card2)
        let index2 = state.cards.firstIndex(where: { $0.id == card2.id })!
        XCTAssertTrue(state.cards[index2].isFaceUp)
        XCTAssertTrue(state.isProcessingMismatch, "Should be processing mismatch")
        
        // Try to choose third card while processing - should be blocked
        let scoreBeforeBlocked = state.score
        state.choose(card3)
        let index3 = state.cards.firstIndex(where: { $0.id == card3.id })!
        
        // Third card should NOT flip during processing
        XCTAssertFalse(state.cards[index3].isFaceUp, "Third card should not flip during mismatch processing")
        XCTAssertEqual(state.score, scoreBeforeBlocked, "Score should not change for blocked selection")
        
        // Wait for delay to complete (increased from 1.6s to 1.7s for CI reliability)
        try? await Task.sleep(for: .seconds(1.7))
        
        // After processing completes, selections should be allowed again
        XCTAssertFalse(state.isProcessingMismatch)
        
        // Now third card should be selectable
        state.choose(card3)
        XCTAssertTrue(state.cards[index3].isFaceUp, "Third card should flip after processing completes")
    }
}
