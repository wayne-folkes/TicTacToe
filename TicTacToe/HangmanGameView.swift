import SwiftUI

struct HangmanGameView: View {
    @StateObject private var gameState = HangmanGameState()
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with GameHeaderView
                GameHeaderView(
                    title: "Hangman",
                    score: gameState.score
                )
                
                // Additional stats
                HStack(spacing: 30) {
                    VStack {
                        Text("Won")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameState.gamesWon)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.successColor)
                    }
                    
                    VStack {
                        Text("Lost")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameState.gamesLost)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.errorColor)
                    }
                }
                
                // Category selector
                categoryPicker
                
                // Stick figure drawing
                HangmanDrawingView(wrongGuesses: gameState.wrongGuesses)
                    .frame(height: 250)
                
                // Word display
                wordDisplay
                
                // Letter keyboard
                letterKeyboard
                
                // Game Over View
                if gameState.isGameOver {
                    GameOverView(
                        message: gameState.hasWon ? "🎉 You Won!" : "😢 Game Over\nThe word was: \(gameState.currentWord)",
                        isSuccess: gameState.hasWon,
                        onPlayAgain: {
                            confettiTask?.cancel()
                            showConfetti = false
                            gameState.startNewGame()
                        },
                        secondaryButtonTitle: "Reset Stats",
                        onSecondaryAction: {
                            gameState.resetStats()
                        }
                    )
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.cardBackground)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .overlay(alignment: .top) {
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onChange(of: gameState.hasWon) { _, won in
            if won {
                SoundManager.shared.play(.win)
                HapticManager.shared.notification(type: .success)
                showConfetti = true
                confettiTask?.cancel()
                confettiTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(3))
                    guard !Task.isCancelled else { return }
                    showConfetti = false
                }
            }
        }
        .onChange(of: gameState.isGameOver) { _, isOver in
            if isOver && !gameState.hasWon {
                SoundManager.shared.play(.lose)
                HapticManager.shared.notification(type: .error)
            }
        }
        .onDisappear {
            confettiTask?.cancel()
        }
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $gameState.selectedCategory) {
            ForEach(WordCategory.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .onChange(of: gameState.selectedCategory) { _, newCategory in
            gameState.setCategory(newCategory)
        }
    }
    
    private var wordDisplay: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(gameState.getDisplayWord())
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
                .tracking(8)
                .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.elevatedCardBackground.opacity(0.6))
        .cornerRadius(12)
    }
    
    private var letterKeyboard: some View {
        GeometryReader { geo in
            let available = geo.size.width
            let spacing: CGFloat = 6
            // Compute a key width that guarantees 10 keys + 9 gaps fit on the first row
            let keyWidth = floor((available - spacing * 9) / 10)
            let row1 = Array("QWERTYUIOP")
            let row2 = Array("ASDFGHJKL")
            let row3 = Array("ZXCVBNM")

            VStack(spacing: 10) {
                // Row 1: QWERTYUIOP
                HStack(spacing: spacing) {
                    ForEach(row1, id: \.self) { letter in
                        letterButton(letter, keyWidth: keyWidth)
                    }
                }
                .frame(maxWidth: .infinity)

                // Row 2: ASDFGHJKL (centered)
                HStack(spacing: spacing) {
                    ForEach(row2, id: \.self) { letter in
                        letterButton(letter, keyWidth: keyWidth)
                    }
                }
                .frame(width: CGFloat(row2.count) * keyWidth + CGFloat(row2.count - 1) * spacing)
                .frame(maxWidth: .infinity)

                // Row 3: ZXCVBNM (centered)
                HStack(spacing: spacing) {
                    ForEach(row3, id: \.self) { letter in
                        letterButton(letter, keyWidth: keyWidth)
                    }
                }
                .frame(width: CGFloat(row3.count) * keyWidth + CGFloat(row3.count - 1) * spacing)
                .frame(maxWidth: .infinity)
            }
        }
        // Approximate total height to avoid layout warnings: 3 rows * 40 height + 2 inter-row spacings
        .frame(height: 3 * 40 + 2 * 10)
    }
    
    private func letterButton(_ letter: Character, keyWidth: CGFloat) -> some View {
        let isGuessed = gameState.guessedLetters.contains(letter)
        let isInWord = gameState.currentWord.contains(letter)
        
        return Button(action: {
            SoundManager.shared.play(.click)
            gameState.guessLetter(letter)
        }) {
            Text(String(letter))
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: keyWidth, height: 40)
                .background(
                    isGuessed
                        ? (isInWord ? Color.successColor.opacity(0.7) : Color.errorColor.opacity(0.7))
                        : Color.hangmanAccent.opacity(0.3)
                )
                .foregroundColor(isGuessed ? .white : .primary)
                .cornerRadius(8)
        }
        .disabled(isGuessed || gameState.isGameOver)
    }
}

// Stick figure drawing view
struct HangmanDrawingView: View {
    let wrongGuesses: Int
    
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            
            // Draw base and pole (always visible)
            drawGallows(context: context, width: width, height: height)
            
            // Draw body parts based on wrong guesses
            if wrongGuesses >= 1 {
                drawHead(context: context, width: width, height: height)
            }
            if wrongGuesses >= 2 {
                drawBody(context: context, width: width, height: height)
            }
            if wrongGuesses >= 3 {
                drawLeftArm(context: context, width: width, height: height)
            }
            if wrongGuesses >= 4 {
                drawRightArm(context: context, width: width, height: height)
            }
            if wrongGuesses >= 5 {
                drawLeftLeg(context: context, width: width, height: height)
            }
            if wrongGuesses >= 6 {
                drawRightLeg(context: context, width: width, height: height)
            }
            if wrongGuesses >= 7 {
                drawFace(context: context, width: width, height: height, sad: false)
            }
            if wrongGuesses >= 8 {
                drawFace(context: context, width: width, height: height, sad: true)
            }
        }
    }
    
    private func drawGallows(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        
        // Base
        path.move(to: CGPoint(x: width * 0.1, y: height * 0.95))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.95))
        
        // Vertical pole
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.95))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.1))
        
        // Horizontal beam
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
        
        // Rope
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.2))
        
        context.stroke(path, with: .color(.brown), lineWidth: 3)
    }
    
    private func drawHead(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let center = CGPoint(x: width * 0.6, y: height * 0.27)
        let radius = height * 0.07
        
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawBody(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.34))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.55))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawLeftArm(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.48))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawRightArm(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.48))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawLeftLeg(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.55))
        path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.7))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawRightLeg(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: width * 0.6, y: height * 0.55))
        path.addLine(to: CGPoint(x: width * 0.68, y: height * 0.7))
        
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
    
    private func drawFace(context: GraphicsContext, width: CGFloat, height: CGFloat, sad: Bool) {
        let centerX = width * 0.6
        let centerY = height * 0.27
        let eyeOffset = height * 0.02
        
        // Eyes
        var eyePath = Path()
        if sad {
            // X eyes for final stage
            eyePath.move(to: CGPoint(x: centerX - eyeOffset - 3, y: centerY - 3))
            eyePath.addLine(to: CGPoint(x: centerX - eyeOffset + 3, y: centerY + 3))
            eyePath.move(to: CGPoint(x: centerX - eyeOffset + 3, y: centerY - 3))
            eyePath.addLine(to: CGPoint(x: centerX - eyeOffset - 3, y: centerY + 3))
            
            eyePath.move(to: CGPoint(x: centerX + eyeOffset - 3, y: centerY - 3))
            eyePath.addLine(to: CGPoint(x: centerX + eyeOffset + 3, y: centerY + 3))
            eyePath.move(to: CGPoint(x: centerX + eyeOffset + 3, y: centerY - 3))
            eyePath.addLine(to: CGPoint(x: centerX + eyeOffset - 3, y: centerY + 3))
        } else {
            // Simple dot eyes
            eyePath.addEllipse(in: CGRect(x: centerX - eyeOffset - 2, y: centerY - 2, width: 4, height: 4))
            eyePath.addEllipse(in: CGRect(x: centerX + eyeOffset - 2, y: centerY - 2, width: 4, height: 4))
        }
        
        context.stroke(eyePath, with: .color(.black), lineWidth: 1.5)
        
        if sad {
            // Sad mouth
            var mouthPath = Path()
            mouthPath.move(to: CGPoint(x: centerX - eyeOffset, y: centerY + eyeOffset * 2))
            mouthPath.addQuadCurve(
                to: CGPoint(x: centerX + eyeOffset, y: centerY + eyeOffset * 2),
                control: CGPoint(x: centerX, y: centerY + eyeOffset)
            )
            context.stroke(mouthPath, with: .color(.black), lineWidth: 1.5)
        }
    }
}

#Preview {
    HangmanGameView()
}

