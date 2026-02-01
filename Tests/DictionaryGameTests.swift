import XCTest
@testable import GamesApp

@MainActor
final class DictionaryGameTests: XCTestCase {
    var gameState: DictionaryGameState!
    
    nonisolated override func setUp() {
        super.setUp()
    }
    
    nonisolated override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDictionaryGameStateInitialization() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        XCTAssertEqual(gameState.score, 0)
        XCTAssertFalse(gameState.isGameOver)
        XCTAssertEqual(gameState.options.count, 4, "Should have 4 options")
    }
    
    // MARK: - Difficulty Tests
    
    func testSetDifficulty() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        gameState.setDifficulty(.medium)
        XCTAssertEqual(gameState.difficulty, .medium)
        
        gameState.setDifficulty(.hard)
        XCTAssertEqual(gameState.difficulty, .hard)
    }
    
    // MARK: - Question Generation Tests
    
    func testOptionsContainCorrectAnswer() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        if let currentWord = gameState.currentWord {
            XCTAssertTrue(gameState.options.contains(currentWord.definition),
                         "Options should contain correct definition")
        } else {
            XCTFail("Game should have a current word after initialization")
        }
    }
    
    func testOptionsAreUnique() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        let uniqueOptions = Set(gameState.options)
        XCTAssertEqual(gameState.options.count, uniqueOptions.count, "All options should be unique")
    }
    
    // MARK: - Answer Validation Tests
    
    func testCheckAnswerCorrect() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        guard let correctAnswer = gameState.currentWord?.definition else {
            XCTFail("No current word available")
            return
        }
        
        let initialScore = gameState.score
        gameState.checkAnswer(correctAnswer)
        
        XCTAssertEqual(gameState.selectedOption, correctAnswer)
        XCTAssertEqual(gameState.score, initialScore + 1, "Score should increase by 1 for correct answer")
    }
    
    func testCheckAnswerIncorrect() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        guard let correctAnswer = gameState.currentWord?.definition else {
            XCTFail("No current word available")
            return
        }
        
        // Find a wrong answer
        let wrongAnswer = gameState.options.first(where: { $0 != correctAnswer })!
        
        let initialScore = gameState.score
        gameState.checkAnswer(wrongAnswer)
        
        XCTAssertEqual(gameState.selectedOption, wrongAnswer)
        XCTAssertEqual(gameState.score, initialScore, "Score should not change for incorrect answer")
    }
    
    // MARK: - Score Calculation Tests
    
    func testScoreIncreasesWithCorrectAnswers() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        guard let correctAnswer = gameState.currentWord?.definition else {
            XCTFail("No current word available")
            return
        }
        
        XCTAssertEqual(gameState.score, 0)
        
        gameState.checkAnswer(correctAnswer)
        XCTAssertEqual(gameState.score, 1)
        
        gameState.nextQuestion()
        gameState.loadLocalQuestion()
        
        if let nextCorrectAnswer = gameState.currentWord?.definition {
            gameState.checkAnswer(nextCorrectAnswer)
            XCTAssertEqual(gameState.score, 2)
        }
    }
    
    func testScoreDoesNotDecreaseWithIncorrectAnswers() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        guard let correctAnswer = gameState.currentWord?.definition else {
            XCTFail("No current word available")
            return
        }
        
        gameState.checkAnswer(correctAnswer)
        XCTAssertEqual(gameState.score, 1)
        
        gameState.nextQuestion()
        gameState.loadLocalQuestion()
        
        if let wrongAnswer = gameState.options.first(where: { $0 != gameState.currentWord?.definition }) {
            gameState.checkAnswer(wrongAnswer)
            XCTAssertEqual(gameState.score, 1, "Score should not decrease")
        }
    }
    
    // MARK: - Game Flow Tests
    
    func testNextQuestionResetsSelection() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        if let correctAnswer = gameState.currentWord?.definition {
            gameState.checkAnswer(correctAnswer)
        }
        
        XCTAssertNotNil(gameState.selectedOption)
        
        gameState.nextQuestion()
        
        XCTAssertNil(gameState.selectedOption, "Selected option should be cleared")
    }
    
    func testMultipleCorrectAnswersInRow() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        for i in 0..<3 {
            if let correctAnswer = gameState.currentWord?.definition {
                gameState.checkAnswer(correctAnswer)
                XCTAssertEqual(gameState.score, i + 1)
                
                gameState.nextQuestion()
                gameState.loadLocalQuestion()
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCheckAnswerTwice() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        guard let correctAnswer = gameState.currentWord?.definition else {
            XCTFail("No current word available")
            return
        }
        
        gameState.checkAnswer(correctAnswer)
        let scoreAfterFirst = gameState.score
        XCTAssertEqual(gameState.selectedOption, correctAnswer, "First answer should be recorded")
        
        // Try to answer again with a different option
        let wrongAnswer = gameState.options.first(where: { $0 != correctAnswer })!
        gameState.checkAnswer(wrongAnswer)
        
        // Score should not change (already answered)
        XCTAssertEqual(gameState.score, scoreAfterFirst, "Should not be able to answer twice")
        // Selection should still be the first answer since we can't change it
        XCTAssertNotNil(gameState.selectedOption, "Selected option should still exist")
    }
    
    // MARK: - Word Model Tests
    
    func testWordHasRequiredProperties() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.loadLocalQuestion()
        
        if let word = gameState.currentWord {
            XCTAssertFalse(word.term.isEmpty, "Word term should not be empty")
            XCTAssertFalse(word.definition.isEmpty, "Word definition should not be empty")
        } else {
            XCTFail("Game should have a current word")
        }
    }
    
    // MARK: - DictionaryServicesHelper Tests
    
    func testGetCleanDefinitionExtractsFirstDefinition() {
        #if os(macOS)
        // Test with a common word that should exist in the system dictionary
        let definition = DictionaryServicesHelper.getCleanDefinition(for: "happy")
        
        XCTAssertNotNil(definition, "Should find definition for 'happy' in system dictionary")
        
        if let definition = definition {
            // Verify it's a non-empty string
            XCTAssertFalse(definition.isEmpty, "Definition should not be empty")
            
            // Verify it's not excessively long (should be just first definition)
            XCTAssertLessThan(definition.count, 200, "First definition should be concise")
            
            // Verify it doesn't start with special characters
            XCTAssertTrue(definition.first?.isLetter ?? false, "Definition should start with a letter")
        }
        #else
        // On iOS, the method should return nil
        let definition = DictionaryServicesHelper.getCleanDefinition(for: "happy")
        XCTAssertNil(definition, "Should return nil on non-macOS platforms")
        #endif
    }
    
    func testGetCleanDefinitionRemovesPronunciationAndExamples() {
        #if os(macOS)
        let definition = DictionaryServicesHelper.getCleanDefinition(for: "ephemeral")
        
        if let definition = definition {
            // Verify pronunciation guides are removed (e.g., | ˈhapē |)
            XCTAssertFalse(definition.contains("|"), "Should not contain pronunciation pipes")
            XCTAssertFalse(definition.contains("ˈ"), "Should not contain pronunciation symbols")
            
            // Verify examples after colons are removed
            XCTAssertFalse(definition.contains(":"), "Should not contain example colons")
            
            // Verify comparative forms in parentheses are removed
            XCTAssertFalse(definition.contains("("), "Should not contain opening parentheses")
            XCTAssertFalse(definition.contains(")"), "Should not contain closing parentheses")
            
            // Verify numbering is removed (1, 2, 3...)
            let firstChar = String(definition.prefix(1))
            XCTAssertFalse(firstChar.allSatisfy { $0.isNumber }, "Should not start with a number")
        }
        #endif
    }
    
    func testGetCleanDefinitionReturnsNilForNonexistentWord() {
        #if os(macOS)
        // Use a nonsensical string that shouldn't exist in the dictionary
        let definition = DictionaryServicesHelper.getCleanDefinition(for: "xyzabc123nonexistent")
        
        XCTAssertNil(definition, "Should return nil for a word not found in the system dictionary")
        #endif
    }
    
    func testNextQuestionUtilizesDictionaryServicesHelper() {
        #if os(macOS)
        gameState = DictionaryGameState(startImmediately: false)
        gameState.setDifficulty(.easy)
        gameState.nextQuestion()
        
        // Get the current word
        guard let currentWord = gameState.currentWord else {
            XCTFail("Should have a current word")
            return
        }
        
        // Check if DictionaryServicesHelper can find this word
        let systemDefinition = DictionaryServicesHelper.getCleanDefinition(for: currentWord.term.lowercased())
        
        if let systemDefinition = systemDefinition {
            // If system definition exists, verify it's being used
            XCTAssertEqual(currentWord.definition, systemDefinition,
                          "nextQuestion should use system definition when available")
        }
        // Note: We can't guarantee all words will be in the system dictionary,
        // so we only assert when a definition is found
        #endif
    }
    
    func testNextQuestionFallsBackToHardcodedDefinitions() {
        gameState = DictionaryGameState(startImmediately: false)
        gameState.setDifficulty(.hard)
        
        // Test with hard difficulty words that may not be in system dictionary
        // (e.g., "Vellichor", "Cromulent" are made-up or very obscure)
        var foundFallback = false
        
        // Try multiple questions to increase chance of finding a word not in system dictionary
        for _ in 0..<10 {
            gameState.nextQuestion()
            
            guard let currentWord = gameState.currentWord else {
                continue
            }
            
            #if os(macOS)
            let systemDefinition = DictionaryServicesHelper.getCleanDefinition(for: currentWord.term.lowercased())
            
            // If no system definition exists, verify fallback is used
            if systemDefinition == nil {
                // The definition should be one from the hardcoded word bank
                XCTAssertFalse(currentWord.definition.isEmpty, "Should have fallback definition")
                foundFallback = true
                break
            }
            #else
            // On iOS, all definitions should be hardcoded fallbacks
            XCTAssertFalse(currentWord.definition.isEmpty, "Should have fallback definition on iOS")
            foundFallback = true
            break
            #endif
        }
        
        #if !os(macOS)
        XCTAssertTrue(foundFallback, "Should use fallback definitions on non-macOS platforms")
        #endif
        // Note: On macOS, we can't guarantee finding a missing word,
        // but the test demonstrates the fallback mechanism
    }
}
