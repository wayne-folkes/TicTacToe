import SwiftUI
import Combine

/// Game logic and state management for the Math Quiz game.
///
/// This class implements a multiple-choice math quiz with three difficulty levels
/// and two game modes (timed challenge and practice). Players answer math questions
/// covering addition, subtraction, multiplication, and division.
///
/// ## Features
/// - **Three Difficulty Levels**: Easy, Medium, Hard
/// - **Two Game Modes**: Timed (60s) and Practice (unlimited)
/// - **Four Operations**: Addition, Subtraction, Multiplication, Division
/// - **Scoring System**: +10 per correct, +5 bonus for streak ≥ 3
/// - **Streak Tracking**: Tracks consecutive correct answers
/// - **Statistics**: Persists best scores and streaks
///
/// ## Question Generation
/// Questions are generated with difficulty-appropriate number ranges:
/// - Easy: 1-20 for addition, 1-10 for multiplication
/// - Medium: 10-100 for addition, includes division
/// - Hard: 50-500 for addition, larger ranges for all operations
@MainActor
final class MathQuizGameState: ObservableObject {
    
    // MARK: - Enums
    
    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var id: String { rawValue }
    }
    
    enum QuizMode: String, CaseIterable, Identifiable {
        case timed = "Timed"
        case practice = "Practice"
        
        var id: String { rawValue }
    }
    
    enum Operation: CaseIterable {
        case add, subtract, multiply, divide
        
        var symbol: String {
            switch self {
            case .add: return "+"
            case .subtract: return "−"
            case .multiply: return "×"
            case .divide: return "÷"
            }
        }
    }
    
    // MARK: - Published Properties
    
    // Question State
    @Published var currentQuestion: String = ""
    @Published var correctAnswer: Int = 0
    @Published var options: [Int] = []
    @Published var selectedAnswer: Int?
    
    // Game State
    @Published var score: Int = 0
    @Published var questionsAnswered: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var isGameOver: Bool = false
    @Published var showingFeedback: Bool = false
    @Published var lastAnswerCorrect: Bool?
    
    // Settings
    @Published var difficulty: Difficulty = .easy
    @Published var mode: QuizMode = .practice
    
    // Timer (timed mode only)
    @Published var timeRemaining: Int?
    private var timerTask: Task<Void, Never>?
    
    // Statistics Persistence
    @AppStorage("mathQuizBestScoreTimed") private var bestScoreTimed: Int = 0
    @AppStorage("mathQuizBestScorePractice") private var bestScorePractice: Int = 0
    @AppStorage("mathQuizBestStreakOverall") private var bestStreakOverall: Int = 0
    
    // MARK: - Computed Properties
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100.0
    }
    
    var bestScore: Int {
        mode == .timed ? bestScoreTimed : bestScorePractice
    }
    
    // MARK: - Initialization
    
    init() {
        // Load persisted best scores on initialization
    }
    
    // MARK: - Game Flow Methods
    
    func startNewQuiz() {
        // Reset game state
        score = 0
        questionsAnswered = 0
        correctAnswers = 0
        streak = 0
        bestStreak = 0
        isGameOver = false
        showingFeedback = false
        lastAnswerCorrect = nil
        selectedAnswer = nil
        
        // Start timer if timed mode
        if mode == .timed {
            timeRemaining = 60
            startTimer()
        } else {
            timeRemaining = nil
        }
        
        // Generate first question
        generateQuestion()
    }
    
    func submitAnswer(_ answer: Int) {
        guard !showingFeedback else { return } // Prevent rapid taps
        
        selectedAnswer = answer
        let isCorrect = (answer == correctAnswer)
        lastAnswerCorrect = isCorrect
        showingFeedback = true
        
        // Update statistics
        questionsAnswered += 1
        
        if isCorrect {
            correctAnswers += 1
            streak += 1
            
            // Update best streak
            if streak > bestStreak {
                bestStreak = streak
            }
            if streak > bestStreakOverall {
                bestStreakOverall = streak
            }
            
            // Calculate score: base 10 + bonus 5 if streak >= 3
            let bonus = (streak >= 3) ? 5 : 0
            score += 10 + bonus
        } else {
            streak = 0
        }
        
        // Delay before next question (1.5 seconds for feedback)
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            
            guard !isGameOver else { return }
            
            // Clear feedback and move to next question
            showingFeedback = false
            lastAnswerCorrect = nil
            selectedAnswer = nil
            generateQuestion()
        }
    }
    
    func endGame() {
        isGameOver = true
        stopTimer()
        
        // Save best scores if exceeded
        if mode == .timed {
            if score > bestScoreTimed {
                bestScoreTimed = score
            }
        } else {
            if score > bestScorePractice {
                bestScorePractice = score
            }
        }
        
        // Statistics will be updated when we integrate with GameStatistics
    }
    
    // MARK: - Question Generation
    
    func generateQuestion() {
        // Determine available operations based on difficulty
        let availableOps: [Operation] = difficulty == .easy ?
            [.add, .subtract, .multiply] :
            [.add, .subtract, .multiply, .divide]
        
        let operation = availableOps.randomElement()!
        
        let (question, answer) = switch operation {
        case .add:
            generateAddition()
        case .subtract:
            generateSubtraction()
        case .multiply:
            generateMultiplication()
        case .divide:
            generateDivision()
        }
        
        currentQuestion = question
        correctAnswer = answer
        options = generateOptions(correct: answer)
    }
    
    private func generateAddition() -> (String, Int) {
        let (min, max) = switch difficulty {
        case .easy: (1, 20)
        case .medium: (10, 100)
        case .hard: (50, 500)
        }
        
        let a = Int.random(in: min...max)
        let b = Int.random(in: min...max)
        let answer = a + b
        
        return ("\(a) + \(b) = ?", answer)
    }
    
    private func generateSubtraction() -> (String, Int) {
        let (minA, maxA, minB, maxB) = switch difficulty {
        case .easy: (10, 50, 1, 20)
        case .medium: (20, 100, 10, 50)
        case .hard: (100, 500, 50, 200)
        }
        
        let a = Int.random(in: minA...maxA)
        let b = Int.random(in: minB...min(maxB, a)) // Ensure positive result
        let answer = a - b
        
        return ("\(a) − \(b) = ?", answer)
    }
    
    private func generateMultiplication() -> (String, Int) {
        let (min, max) = switch difficulty {
        case .easy: (1, 10)
        case .medium: (5, 15)
        case .hard: (10, 25)
        }
        
        let a = Int.random(in: min...max)
        let b = Int.random(in: min...max)
        let answer = a * b
        
        return ("\(a) × \(b) = ?", answer)
    }
    
    private func generateDivision() -> (String, Int) {
        // Division not available in easy mode
        if difficulty == .easy {
            return generateMultiplication()
        }
        
        let (min, max) = switch difficulty {
        case .easy: (2, 12) // Not used, but needed for exhaustive switch
        case .medium: (2, 12)
        case .hard: (5, 20)
        }
        
        // Generate even division (no remainders)
        let result = Int.random(in: min...max)
        let divisor = Int.random(in: 2...12)
        let dividend = result * divisor
        
        return ("\(dividend) ÷ \(divisor) = ?", result)
    }
    
    // MARK: - Answer Generation
    
    private func generateOptions(correct: Int) -> [Int] {
        var options: Set<Int> = [correct]
        
        // Generate 3 plausible wrong answers
        var attempts = 0
        while options.count < 4 && attempts < 20 {
            let wrong = generateWrongAnswer(correct: correct)
            if wrong > 0 { // Ensure positive answers only
                options.insert(wrong)
            }
            attempts += 1
        }
        
        // If we couldn't generate enough unique options, fill with simple variations
        while options.count < 4 {
            let offset = Int.random(in: 1...10)
            options.insert(correct + offset)
        }
        
        return options.shuffled()
    }
    
    private func generateWrongAnswer(correct: Int) -> Int {
        let strategy = Int.random(in: 0...2)
        
        switch strategy {
        case 0:
            // Strategy 1: Small offset (±1 to ±5)
            let offset = Int.random(in: 1...5) * (Bool.random() ? 1 : -1)
            return correct + offset
            
        case 1:
            // Strategy 2: Off-by-ten error
            let offset = 10 * (Bool.random() ? 1 : -1)
            return correct + offset
            
        default:
            // Strategy 3: Larger variation (±10% to ±30%)
            let percentage = Double.random(in: 0.1...0.3)
            let offset = Int(Double(correct) * percentage) * (Bool.random() ? 1 : -1)
            return correct + offset
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timerTask?.cancel()
        
        timerTask = Task {
            while let time = timeRemaining, time > 0 {
                try? await Task.sleep(for: .seconds(1))
                
                guard !Task.isCancelled else { return }
                
                timeRemaining = time - 1
                
                // End game when timer reaches 0
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        timerTask?.cancel()
    }
}
