import SwiftUI

struct MemoryGameView: View {
    @StateObject private var gameState = MemoryGameState()
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            // Clean background following Apple HIG
            Color.cardBackground
                .ignoresSafeArea()
            
            VStack {
                // Header with GameHeaderView
                GameHeaderView(
                    title: "Memory Game",
                    score: gameState.score,
                    scoreColor: .primary
                )
                
                // Theme Selector
                Picker("Theme", selection: Binding(
                    get: { gameState.currentTheme },
                    set: { gameState.toggleTheme($0) }
                )) {
                    ForEach(MemoryGameState.MemoryTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(gameState.cards) { card in
                            CardView(card: card)
                                .aspectRatio(2/3, contentMode: .fit)
                                .onTapGesture {
                                    SoundManager.shared.play(.flip)
                                    HapticManager.shared.impact(style: .light)
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        gameState.choose(card)
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                if gameState.isGameOver {
                    GameOverView(
                        message: "🎉 Game Complete!",
                        isSuccess: true,
                        onPlayAgain: {
                            confettiTask?.cancel()
                            showConfetti = false
                            withAnimation {
                                gameState.startNewGame()
                            }
                        }
                    )
                    .padding(.horizontal)
                }
            }
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: gameState.isGameOver) { _, newValue in
            if newValue {
                SoundManager.shared.play(.win)
                HapticManager.shared.notification(type: .success)
                withAnimation(.easeIn(duration: 0.3)) {
                    showConfetti = true
                }
                confettiTask?.cancel()
                confettiTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(4))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeOut(duration: 0.3)) {
                        showConfetti = false
                    }
                }
            }
        }
        .onDisappear {
            confettiTask?.cancel()
        }
    }
}

struct CardView: View {
    let card: MemoryCard
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if card.isFaceUp || card.isMatched {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.elevatedCardBackground)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.memoryAccent, lineWidth: 2)
                        
                    Text(card.content)
                        .font(.system(size: geometry.size.width * 0.7))
                        .opacity(card.isMatched ? 0.5 : 1)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.memoryAccent, Color.memoryAccent.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
            }
            .rotation3DEffect(Angle.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
    }
}

#Preview {
    MemoryGameView()
}
