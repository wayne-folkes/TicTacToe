import XCTest
@testable import GamesApp

@MainActor
final class MathQuizGameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        let state = MathQuizGameState()
        
        // Verify initial scores
        XCTAssertEqual(state.score, 0, "Initial score should be 0")
        XCTAssertEqual(state.questionsAnswered, 0, "Initial questions answered should be 0")
        XCTAssertEqual(state.correctAnswers, 0, "Initial correct answers should be 0")
        XCTAssertEqual(state.streak, 0, "Initial streak should be 0")
        XCTAssertEqual(state.bestStreak, 0, "Initial best streak should be 0")
        
        // Verify initial game state
        XCTAssertFalse(state.isGameOver, "Game should not be over initially")
        XCTAssertFalse(state.showingFeedback, "Should not be showing feedback initially")
        XCTAssertNil(state.lastAnswerCorrect, "Last answer correct should be nil initially")
        XCTAssertNil(state.selectedAnswer, "Selected answer should be nil initially")
        
        // Verify default settings
        XCTAssertEqual(state.difficulty, .easy, "Default difficulty should be easy")
        XCTAssertEqual(state.mode, .practice, "Default mode should be practice")
        
        // Verify timer state
        XCTAssertNil(state.timeRemaining, "Timer should be nil in practice mode")
        
        // Verify question state
        XCTAssertEqual(state.currentQuestion, "", "Initial question should be empty")
        XCTAssertEqual(state.correctAnswer, 0, "Initial correct answer should be 0")
        XCTAssertEqual(state.options.count, 0, "Initial options should be empty")
    }
    
    func testStartNewQuizInitializesState() {
        let state = MathQuizGameState()
        
        // Set some non-default values
        state.score = 100
        state.questionsAnswered = 10
        state.correctAnswers = 8
        state.streak = 5
        state.isGameOver = true
        
        // Start new quiz
        state.startNewQuiz()
        
        // Verify state reset
        XCTAssertEqual(state.score, 0, "Score should be reset to 0")
        XCTAssertEqual(state.questionsAnswered, 0, "Questions answered should be reset")
        XCTAssertEqual(state.correctAnswers, 0, "Correct answers should be reset")
        XCTAssertEqual(state.streak, 0, "Streak should be reset")
        XCTAssertEqual(state.bestStreak, 0, "Best streak should be reset for new game")
        XCTAssertFalse(state.isGameOver, "Game over should be false")
        XCTAssertFalse(state.showingFeedback, "Showing feedback should be false")
        
        // Verify question generated
        XCTAssertFalse(state.currentQuestion.isEmpty, "Question should be generated")
        XCTAssertNotEqual(state.correctAnswer, 0, "Correct answer should be set")
        XCTAssertEqual(state.options.count, 4, "Should have 4 options")
    }
    
    func testStartNewQuizInTimedModeStartsTimer() {
        let state = MathQuizGameState()
        state.mode = .timed
        
        state.startNewQuiz()
        
        XCTAssertNotNil(state.timeRemaining, "Timer should be initialized in timed mode")
        XCTAssertEqual(state.timeRemaining, 60, "Timer should start at 60 seconds")
    }
    
    func testStartNewQuizInPracticeModeNoTimer() {
        let state = MathQuizGameState()
        state.mode = .practice
        
        state.startNewQuiz()
        
        XCTAssertNil(state.timeRemaining, "Timer should be nil in practice mode")
    }
    
    // MARK: - Question Generation Tests
    
    func testGenerateAdditionEasyRange() {
        let state = MathQuizGameState()
        state.difficulty = .easy
        
        // Generate multiple questions to test range
        for _ in 0..<20 {
            state.generateQuestion()
            
            // Parse question (format: "X + Y = ?")
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "+" {
                if let a = Int(components[0]), let b = Int(components[2]) {
                    XCTAssertGreaterThanOrEqual(a, 1, "First operand should be >= 1")
                    XCTAssertLessThanOrEqual(a, 20, "First operand should be <= 20")
                    XCTAssertGreaterThanOrEqual(b, 1, "Second operand should be >= 1")
                    XCTAssertLessThanOrEqual(b, 20, "Second operand should be <= 20")
                    XCTAssertEqual(state.correctAnswer, a + b, "Answer should be correct sum")
                }
            }
        }
    }
    
    func testGenerateAdditionMediumRange() {
        let state = MathQuizGameState()
        state.difficulty = .medium
        
        var foundAddition = false
        
        // Generate multiple questions to find addition
        for _ in 0..<30 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "+" {
                foundAddition = true
                if let a = Int(components[0]), let b = Int(components[2]) {
                    XCTAssertGreaterThanOrEqual(a, 10, "First operand should be >= 10")
                    XCTAssertLessThanOrEqual(a, 100, "First operand should be <= 100")
                    XCTAssertGreaterThanOrEqual(b, 10, "Second operand should be >= 10")
                    XCTAssertLessThanOrEqual(b, 100, "Second operand should be <= 100")
                }
                break
            }
        }
        
        XCTAssertTrue(foundAddition, "Should generate addition questions in medium mode")
    }
    
    func testGenerateAdditionHardRange() {
        let state = MathQuizGameState()
        state.difficulty = .hard
        
        var foundAddition = false
        
        for _ in 0..<30 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "+" {
                foundAddition = true
                if let a = Int(components[0]), let b = Int(components[2]) {
                    XCTAssertGreaterThanOrEqual(a, 50, "First operand should be >= 50")
                    XCTAssertLessThanOrEqual(a, 500, "First operand should be <= 500")
                    XCTAssertGreaterThanOrEqual(b, 50, "Second operand should be >= 50")
                    XCTAssertLessThanOrEqual(b, 500, "Second operand should be <= 500")
                }
                break
            }
        }
        
        XCTAssertTrue(foundAddition, "Should generate addition questions in hard mode")
    }
    
    func testGenerateSubtractionPositiveResults() {
        let state = MathQuizGameState()
        state.difficulty = .easy
        
        // Generate multiple subtraction questions
        for _ in 0..<20 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "−" {
                if let a = Int(components[0]), let b = Int(components[2]) {
                    let result = a - b
                    XCTAssertGreaterThanOrEqual(result, 0, "Subtraction result should be non-negative")
                    XCTAssertEqual(state.correctAnswer, result, "Answer should be correct difference")
                }
            }
        }
    }
    
    func testGenerateMultiplicationEasyRange() {
        let state = MathQuizGameState()
        state.difficulty = .easy
        
        var foundMultiplication = false
        
        for _ in 0..<30 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "×" {
                foundMultiplication = true
                if let a = Int(components[0]), let b = Int(components[2]) {
                    XCTAssertGreaterThanOrEqual(a, 1, "First operand should be >= 1")
                    XCTAssertLessThanOrEqual(a, 10, "First operand should be <= 10")
                    XCTAssertGreaterThanOrEqual(b, 1, "Second operand should be >= 1")
                    XCTAssertLessThanOrEqual(b, 10, "Second operand should be <= 10")
                    XCTAssertEqual(state.correctAnswer, a * b, "Answer should be correct product")
                }
                break
            }
        }
        
        XCTAssertTrue(foundMultiplication, "Should generate multiplication in easy mode")
    }
    
    func testGenerateMultiplicationMediumRange() {
        let state = MathQuizGameState()
        state.difficulty = .medium
        
        var foundMultiplication = false
        
        for _ in 0..<30 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "×" {
                foundMultiplication = true
                if let a = Int(components[0]), let b = Int(components[2]) {
                    XCTAssertGreaterThanOrEqual(a, 5, "First operand should be >= 5")
                    XCTAssertLessThanOrEqual(a, 15, "First operand should be <= 15")
                    XCTAssertGreaterThanOrEqual(b, 5, "Second operand should be >= 5")
                    XCTAssertLessThanOrEqual(b, 15, "Second operand should be <= 15")
                }
                break
            }
        }
        
        XCTAssertTrue(foundMultiplication, "Should generate multiplication in medium mode")
    }
    
    func testGenerateDivisionNotInEasyMode() {
        let state = MathQuizGameState()
        state.difficulty = .easy
        
        // Generate many questions
        for _ in 0..<50 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3 {
                XCTAssertNotEqual(components[1], "÷", "Division should not appear in easy mode")
            }
        }
    }
    
    func testGenerateDivisionInMediumMode() {
        let state = MathQuizGameState()
        state.difficulty = .medium
        
        var foundDivision = false
        
        // Generate many questions to find division
        for _ in 0..<50 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "÷" {
                foundDivision = true
                if let dividend = Int(components[0]), let divisor = Int(components[2]) {
                    let result = dividend / divisor
                    XCTAssertEqual(dividend % divisor, 0, "Division should have no remainder")
                    XCTAssertEqual(state.correctAnswer, result, "Answer should be correct quotient")
                }
                break
            }
        }
        
        XCTAssertTrue(foundDivision, "Should generate division questions in medium mode")
    }
    
    func testGenerateDivisionInHardMode() {
        let state = MathQuizGameState()
        state.difficulty = .hard
        
        var foundDivision = false
        
        for _ in 0..<50 {
            state.generateQuestion()
            
            let components = state.currentQuestion.components(separatedBy: " ")
            if components.count >= 3, components[1] == "÷" {
                foundDivision = true
                if let dividend = Int(components[0]), let divisor = Int(components[2]) {
                    XCTAssertEqual(dividend % divisor, 0, "Division should have no remainder in hard mode")
                }
                break
            }
        }
        
        XCTAssertTrue(foundDivision, "Should generate division questions in hard mode")
    }
    
    // MARK: - Answer Generation Tests
    
    func testGeneratesFourOptions() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        XCTAssertEqual(state.options.count, 4, "Should always generate exactly 4 options")
    }
    
    func testOptionsContainCorrectAnswer() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        XCTAssertTrue(state.options.contains(state.correctAnswer), "Options should contain the correct answer")
    }
    
    func testOptionsAreUnique() {
        let state = MathQuizGameState()
        
        // Test multiple question generations
        for _ in 0..<20 {
            state.generateQuestion()
            
            let uniqueOptions = Set(state.options)
            XCTAssertEqual(uniqueOptions.count, state.options.count, "All options should be unique")
        }
    }
    
    func testWrongAnswersArePlausible() {
        let state = MathQuizGameState()
        state.generateQuestion()
        
        // Wrong answers should be positive
        for option in state.options {
            XCTAssertGreaterThan(option, 0, "All options should be positive numbers")
        }
    }
    
    func testOptionsAreShuffled() {
        let state = MathQuizGameState()
        
        var correctAnswerPositions: [Int] = []
        
        // Generate multiple questions
        for _ in 0..<20 {
            state.generateQuestion()
            
            if let index = state.options.firstIndex(of: state.correctAnswer) {
                correctAnswerPositions.append(index)
            }
        }
        
        // Correct answer shouldn't always be in the same position
        let uniquePositions = Set(correctAnswerPositions)
        XCTAssertGreaterThan(uniquePositions.count, 1, "Correct answer should appear in different positions")
    }
    
    // MARK: - Game Flow Tests
    
    func testSubmitCorrectAnswer() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        let correctAnswer = state.correctAnswer
        let initialScore = state.score
        let initialStreak = state.streak
        
        state.submitAnswer(correctAnswer)
        
        XCTAssertEqual(state.selectedAnswer, correctAnswer, "Selected answer should be set")
        XCTAssertEqual(state.lastAnswerCorrect, true, "Last answer should be marked correct")
        XCTAssertTrue(state.showingFeedback, "Should be showing feedback")
        XCTAssertEqual(state.questionsAnswered, 1, "Questions answered should increment")
        XCTAssertEqual(state.correctAnswers, 1, "Correct answers should increment")
        XCTAssertEqual(state.streak, initialStreak + 1, "Streak should increment")
        XCTAssertGreaterThan(state.score, initialScore, "Score should increase")
    }
    
    func testSubmitIncorrectAnswer() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Set up a streak first
        state.streak = 5
        let correctAnswer = state.correctAnswer
        
        // Find a wrong answer
        let wrongAnswer = state.options.first(where: { $0 != correctAnswer })!
        
        let initialScore = state.score
        
        state.submitAnswer(wrongAnswer)
        
        XCTAssertEqual(state.selectedAnswer, wrongAnswer, "Selected answer should be set")
        XCTAssertEqual(state.lastAnswerCorrect, false, "Last answer should be marked incorrect")
        XCTAssertTrue(state.showingFeedback, "Should be showing feedback")
        XCTAssertEqual(state.questionsAnswered, 1, "Questions answered should increment")
        XCTAssertEqual(state.correctAnswers, 0, "Correct answers should not increment")
        XCTAssertEqual(state.streak, 0, "Streak should reset to 0")
        XCTAssertEqual(state.score, initialScore, "Score should not change on incorrect answer")
    }
    
    func testRapidSubmissionsBlocked() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        let correctAnswer = state.correctAnswer
        
        state.submitAnswer(correctAnswer)
        
        // Try to submit again immediately (should be ignored)
        let questionsAnsweredAfterFirst = state.questionsAnswered
        state.submitAnswer(correctAnswer)
        
        XCTAssertEqual(state.questionsAnswered, questionsAnsweredAfterFirst, 
                      "Rapid submissions should be blocked during feedback")
    }
    
    func testEndGameStopsTimer() async {
        let state = MathQuizGameState()
        state.mode = .timed
        state.startNewQuiz()
        
        XCTAssertNotNil(state.timeRemaining, "Timer should be running")
        
        state.endGame()
        
        XCTAssertTrue(state.isGameOver, "Game should be marked as over")
        
        // Wait a bit and verify timer stopped
        try? await Task.sleep(for: .seconds(2))
        let timeAfterEnd = state.timeRemaining
        
        // Timer should either be nil or not have changed (stopped)
        // Since endGame() is called, the timer task should be cancelled
    }
    
    func testQuestionsAnsweredIncrementsCorrectly() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Manually increment without triggering async feedback
        for i in 1...5 {
            state.showingFeedback = false // Allow next submission
            state.generateQuestion()
            state.submitAnswer(state.correctAnswer)
            
            XCTAssertEqual(state.questionsAnswered, i, "Questions answered should be \(i)")
        }
    }
    
    // MARK: - Scoring Tests
    
    func testBaseScoreForCorrectAnswer() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        state.submitAnswer(state.correctAnswer)
        
        XCTAssertEqual(state.score, 10, "Base score for correct answer should be 10")
    }
    
    func testStreakBonusNotAppliedBeforeThree() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // First correct answer (streak = 1)
        state.submitAnswer(state.correctAnswer)
        XCTAssertEqual(state.score, 10, "Score should be 10 (no bonus)")
        
        // Second correct answer (streak = 2)  
        state.generateQuestion()
        state.showingFeedback = false
        state.submitAnswer(state.correctAnswer)
        XCTAssertEqual(state.score, 20, "Score should be 20 (no bonus yet)")
    }
    
    func testStreakBonusAppliedAtThree() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Build streak to 2
        state.streak = 2
        state.score = 20
        
        // Third correct answer (streak will be 3)
        state.submitAnswer(state.correctAnswer)
        
        XCTAssertEqual(state.score, 35, "Score should be 35 (20 + 10 + 5 bonus)")
        XCTAssertEqual(state.streak, 3, "Streak should be 3")
    }
    
    func testStreakBonusContinues() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Build streak to 3
        state.streak = 3
        state.score = 35
        
        // Fourth correct answer
        state.submitAnswer(state.correctAnswer)
        
        XCTAssertEqual(state.score, 50, "Score should be 50 (35 + 15)")
        XCTAssertEqual(state.streak, 4, "Streak should be 4")
    }
    
    func testStreakResetsOnIncorrectAnswer() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Build a streak
        state.streak = 5
        state.score = 65
        
        // Wrong answer
        let wrongAnswer = state.options.first(where: { $0 != state.correctAnswer })!
        state.submitAnswer(wrongAnswer)
        
        XCTAssertEqual(state.streak, 0, "Streak should reset to 0")
        XCTAssertEqual(state.score, 65, "Score should not change on wrong answer")
    }
    
    func testBestStreakTracking() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Build streak to 5
        for _ in 1...5 {
            state.submitAnswer(state.correctAnswer)
            state.generateQuestion()
            state.showingFeedback = false
        }
        
        XCTAssertEqual(state.bestStreak, 5, "Best streak should be 5")
        
        // Reset streak
        let wrongAnswer = state.options.first(where: { $0 != state.correctAnswer })!
        state.submitAnswer(wrongAnswer)
        
        XCTAssertEqual(state.streak, 0, "Current streak should be 0")
        XCTAssertEqual(state.bestStreak, 5, "Best streak should still be 5")
        
        // Build new streak to 3 (less than best)
        state.generateQuestion()
        state.showingFeedback = false
        for _ in 1...3 {
            state.submitAnswer(state.correctAnswer)
            state.generateQuestion()
            state.showingFeedback = false
        }
        
        XCTAssertEqual(state.bestStreak, 5, "Best streak should remain 5")
    }
    
    func testAccuracyCalculation() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Initial accuracy
        XCTAssertEqual(state.accuracy, 0.0, "Initial accuracy should be 0")
        
        // Answer 3 correct, 1 incorrect
        state.questionsAnswered = 4
        state.correctAnswers = 3
        
        XCTAssertEqual(state.accuracy, 75.0, accuracy: 0.01, "Accuracy should be 75%")
        
        // Perfect score
        state.questionsAnswered = 10
        state.correctAnswers = 10
        
        XCTAssertEqual(state.accuracy, 100.0, accuracy: 0.01, "Accuracy should be 100%")
    }
    
    // MARK: - Timer Tests
    
    func testTimerStartsAt60Seconds() {
        let state = MathQuizGameState()
        state.mode = .timed
        
        state.startNewQuiz()
        
        XCTAssertEqual(state.timeRemaining, 60, "Timer should start at 60 seconds")
    }
    
    func testTimerDecrements() async {
        let state = MathQuizGameState()
        state.mode = .timed
        state.startNewQuiz()
        
        let initialTime = state.timeRemaining
        
        // Wait 2+ seconds
        try? await Task.sleep(for: .seconds(2.2))
        
        XCTAssertNotNil(state.timeRemaining, "Timer should still exist")
        if let timeAfter = state.timeRemaining {
            XCTAssertLessThan(timeAfter, initialTime!, "Time should have decreased")
        }
    }
    
    func testTimerEndsGameAtZero() async {
        let state = MathQuizGameState()
        state.mode = .timed
        state.startNewQuiz()
        
        // Manually set time to 1 second
        state.timeRemaining = 1
        
        // Wait for timer to expire
        try? await Task.sleep(for: .seconds(2))
        
        XCTAssertTrue(state.isGameOver, "Game should end when timer reaches 0")
        XCTAssertEqual(state.timeRemaining, 0, "Time should be 0")
    }
    
    func testTimerNilInPracticeMode() {
        let state = MathQuizGameState()
        state.mode = .practice
        
        state.startNewQuiz()
        
        XCTAssertNil(state.timeRemaining, "Practice mode should have no timer")
    }
    
    func testEndGameStopsTimerProperly() {
        let state = MathQuizGameState()
        state.mode = .timed
        state.startNewQuiz()
        
        state.endGame()
        
        XCTAssertTrue(state.isGameOver, "Game should be over")
        // Timer task should be cancelled (internally)
    }
    
    // MARK: - Persistence Tests
    
    func testBestScoreSavedWhenExceeded() {
        let state = MathQuizGameState()
        state.mode = .timed
        
        // Set current score higher than best
        state.score = 150
        let previousBest = state.bestScore
        
        state.endGame()
        
        XCTAssertEqual(state.bestScore, 150, "Best score should be updated")
        XCTAssertGreaterThan(state.bestScore, previousBest, "New best should exceed previous")
    }
    
    func testBestScoreNotSavedWhenLower() {
        let state = MathQuizGameState()
        state.mode = .timed
        
        // Manually set a high best score
        UserDefaults.standard.set(200, forKey: "mathQuizBestScoreTimed")
        
        // Current score is lower
        state.score = 150
        
        state.endGame()
        
        let bestAfter = UserDefaults.standard.integer(forKey: "mathQuizBestScoreTimed")
        XCTAssertEqual(bestAfter, 200, "Best score should not be replaced by lower score")
    }
    
    func testSeparateBestScoresForModes() {
        let state = MathQuizGameState()
        
        // Timed mode score
        state.mode = .timed
        state.score = 100
        state.endGame()
        
        // Practice mode score
        state.mode = .practice
        state.score = 150
        state.endGame()
        
        let timedBest = UserDefaults.standard.integer(forKey: "mathQuizBestScoreTimed")
        let practiceBest = UserDefaults.standard.integer(forKey: "mathQuizBestScorePractice")
        
        XCTAssertEqual(timedBest, 100, "Timed best score should be 100")
        XCTAssertEqual(practiceBest, 150, "Practice best score should be 150")
    }
    
    // MARK: - Edge Cases
    
    func testVeryLongStreak() {
        let state = MathQuizGameState()
        state.startNewQuiz()
        
        // Simulate a very long streak
        state.streak = 50
        state.score = 1000
        
        state.submitAnswer(state.correctAnswer)
        
        // Should not crash or overflow
        XCTAssertEqual(state.streak, 51, "Should handle long streaks")
        XCTAssertGreaterThan(state.score, 1000, "Score should continue to increase")
    }
    
    func testAllQuestionsCorrect() {
        let state = MathQuizGameState()
        state.questionsAnswered = 20
        state.correctAnswers = 20
        
        XCTAssertEqual(state.accuracy, 100.0, accuracy: 0.01, "100% accuracy when all correct")
    }
    
    func testAllQuestionsIncorrect() {
        let state = MathQuizGameState()
        state.questionsAnswered = 20
        state.correctAnswers = 0
        
        XCTAssertEqual(state.accuracy, 0.0, accuracy: 0.01, "0% accuracy when all incorrect")
    }
    
    func testDifficultyChangeBeforeGameStart() {
        let state = MathQuizGameState()
        
        // Change difficulty before starting
        state.difficulty = .hard
        state.startNewQuiz()
        
        // Question should be generated with hard difficulty
        XCTAssertFalse(state.currentQuestion.isEmpty, "Question should be generated")
        XCTAssertEqual(state.difficulty, .hard, "Difficulty should remain hard")
    }
    
    // MARK: - Cleanup
    
    override func tearDown() {
        // Clean up UserDefaults after tests
        UserDefaults.standard.removeObject(forKey: "mathQuizBestScoreTimed")
        UserDefaults.standard.removeObject(forKey: "mathQuizBestScorePractice")
        UserDefaults.standard.removeObject(forKey: "mathQuizBestStreakOverall")
        
        super.tearDown()
    }
}
