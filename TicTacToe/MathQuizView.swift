import SwiftUI

struct MathQuizView: View {
    @StateObject private var gameState = MathQuizGameState()
    @Environment(\.colorScheme) var colorScheme
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with score, accuracy, and streak
                GameHeaderView(
                    title: "Math Quiz",
                    score: gameState.score,
                    scoreColor: .primary
                )
                .padding(.top, 16)
                
                // Stats Row
                HStack(spacing: 16) {
                    // Accuracy
                    StatBadge(
                        label: "Accuracy",
                        value: String(format: "%.0f%%", gameState.accuracy),
                        color: accuracyColor
                    )
                    
                    // Streak
                    StatBadge(
                        label: "Streak",
                        value: streakDisplay,
                        color: .orange
                    )
                }
                .padding(.horizontal, 16)
                
                // Timer Bar (Timed Mode Only)
                if gameState.mode == .timed, let time = gameState.timeRemaining {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Time Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(time)s")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(timerColor(for: time))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(timerColor(for: time))
                                    .frame(width: geometry.size.width * CGFloat(time) / 60.0)
                                    .animation(.linear(duration: 1.0), value: time)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Settings (only shown before game starts or when game is over)
                if !gameState.isGameOver && gameState.questionsAnswered == 0 {
                    VStack(spacing: 16) {
                        // Difficulty Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Difficulty")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Difficulty", selection: $gameState.difficulty) {
                                ForEach(MathQuizGameState.Difficulty.allCases) { diff in
                                    Text(diff.rawValue).tag(diff)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Mode Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Mode", selection: $gameState.mode) {
                                ForEach(MathQuizGameState.QuizMode.allCases) { mode in
                                    HStack {
                                        Text(mode == .timed ? "⏱️" : "📚")
                                        Text(mode.rawValue)
                                    }.tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Start Button
                        Button(action: {
                            SoundManager.shared.play(.click)
                            HapticManager.shared.impact(style: .medium)
                            withAnimation {
                                gameState.startNewQuiz()
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Quiz")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Question Display (only when game is active)
                if !gameState.isGameOver && gameState.questionsAnswered > 0 {
                    VStack(spacing: 24) {
                        // Question
                        Text(gameState.currentQuestion)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.cardBackground)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 16)
                        
                        // Answer Buttons (2×2 Grid)
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(Array(gameState.options.enumerated()), id: \.offset) { index, option in
                                AnswerButton(
                                    number: index + 1,
                                    answer: option,
                                    isSelected: gameState.selectedAnswer == option,
                                    isCorrect: gameState.showingFeedback && option == gameState.correctAnswer,
                                    isIncorrect: gameState.showingFeedback && gameState.selectedAnswer == option && gameState.lastAnswerCorrect == false,
                                    isDisabled: gameState.showingFeedback,
                                    onTap: {
                                        SoundManager.shared.play(.tap)
                                        HapticManager.shared.impact(style: .light)
                                        gameState.submitAnswer(option)
                                        
                                        if gameState.lastAnswerCorrect == false {
                                            withAnimation(.default.repeatCount(3, autoreverses: true)) {
                                                shakeOffset = 10
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                shakeOffset = 0
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .offset(x: shakeOffset)
                    }
                }
                
                // Game Over Overlay
                if gameState.isGameOver {
                    GameOverCard(
                        score: gameState.score,
                        questionsAnswered: gameState.questionsAnswered,
                        correctAnswers: gameState.correctAnswers,
                        accuracy: gameState.accuracy,
                        bestStreak: gameState.bestStreak,
                        bestScore: gameState.bestScore,
                        isNewBest: gameState.score > gameState.bestScore,
                        onPlayAgain: {
                            SoundManager.shared.play(.click)
                            HapticManager.shared.impact(style: .medium)
                            withAnimation {
                                gameState.startNewQuiz()
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.gray.opacity(0.05))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
        .focusable()
        .onKeyPress { press in
            handleKeyPress(press)
        }
        #endif
    }
    
    // MARK: - Helper Views
    
    private var accuracyColor: Color {
        let acc = gameState.accuracy
        if acc >= 80 { return .green }
        if acc >= 60 { return .orange }
        return .red
    }
    
    private var streakDisplay: String {
        let streak = gameState.streak
        if streak == 0 { return "0" }
        let fireCount = min(streak, 5)
        let fires = String(repeating: "🔥", count: fireCount)
        return "\(fires) \(streak)"
    }
    
    private func timerColor(for time: Int) -> Color {
        if time > 30 { return .green }
        if time > 10 { return .orange }
        return .red
    }
    
    // MARK: - Keyboard Support
    
    #if os(macOS)
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Don't process keys during feedback or game over
        guard !gameState.showingFeedback && !gameState.isGameOver else {
            return .ignored
        }
        
        // N key to start new game
        if press.characters == "n" && gameState.questionsAnswered == 0 {
            gameState.startNewQuiz()
            return .handled
        }
        
        // Number keys 1-4 for answer selection (only during active game)
        guard gameState.questionsAnswered > 0,
              let number = Int(press.characters),
              (1...4).contains(number),
              gameState.options.count >= number else {
            return .ignored
        }
        
        let answer = gameState.options[number - 1]
        gameState.submitAnswer(answer)
        
        if gameState.lastAnswerCorrect == false {
            withAnimation(.default.repeatCount(3, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shakeOffset = 0
            }
        }
        
        return .handled
    }
    #endif
}

// MARK: - Stat Badge

struct StatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Answer Button

struct AnswerButton: View {
    let number: Int
    let answer: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("\(answer)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isIncorrect {
            return Color.red.opacity(0.2)
        } else {
            return Color.cardBackground
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else {
            return .primary
        }
    }
}

// MARK: - Game Over Card

struct GameOverCard: View {
    let score: Int
    let questionsAnswered: Int
    let correctAnswers: Int
    let accuracy: Double
    let bestStreak: Int
    let bestScore: Int
    let isNewBest: Bool
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Score
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                if isNewBest {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("New Best Score!")
                        Image(systemName: "star.fill")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                }
            }
            
            Divider()
            
            // Statistics
            VStack(spacing: 12) {
                StatRow(label: "Questions Answered", value: "\(questionsAnswered)")
                StatRow(label: "Correct Answers", value: "\(correctAnswers)")
                StatRow(label: "Accuracy", value: String(format: "%.1f%%", accuracy))
                StatRow(label: "Best Streak", value: "\(bestStreak)")
                StatRow(label: "Previous Best", value: "\(bestScore)")
            }
            
            // Play Again Button
            Button(action: onPlayAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        MathQuizView()
    }
}
