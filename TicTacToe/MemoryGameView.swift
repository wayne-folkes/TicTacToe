import SwiftUI

struct MemoryGameView: View {
    @StateObject private var gameState = MemoryGameState()
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    @State private var shakeOffsets: [UUID: CGFloat] = [:]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with GameHeaderView
            GameHeaderView(
                title: "Memory Game",
                score: gameState.score,
                scoreColor: .primary
            )
            .padding(.top, 16)
            
            // Theme Selector
            HStack {
                Text("Theme:")
                    .font(.headline)
                
                Picker("Theme", selection: Binding(
                    get: { gameState.currentTheme },
                    set: { gameState.toggleTheme($0) }
                )) {
                    ForEach(MemoryGameState.MemoryTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(gameState.cards) { card in
                        CardView(
                            card: card,
                            isDisabled: gameState.isProcessingMismatch || card.isFaceUp || card.isMatched
                        )
                        .aspectRatio(2/3, contentMode: .fit)
                        .offset(x: shakeOffsets[card.id] ?? 0)
                        .onTapGesture {
                            // Disable taps during mismatch processing
                            guard !gameState.isProcessingMismatch else { return }
                            
                            SoundManager.shared.play(.flip)
                            HapticManager.shared.impact(style: .light)
                            withAnimation(.easeInOut(duration: 0.5)) {
                                gameState.choose(card)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .onChange(of: gameState.mismatchedCardIds) { _, ids in
                // Trigger shake animation for mismatched cards
                for cardId in ids where !ids.isEmpty {
                    withAnimation(.default.repeatCount(3).speed(6)) {
                        shakeOffsets[cardId] = 10
                    }
                    // Reset after animation completes
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.5))
                        shakeOffsets[cardId] = 0
                    }
                }
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
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
    let isDisabled: Bool
    
    @State private var isHovered = false
    
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
                        .shadow(color: .black.opacity(isHovered && !isDisabled ? 0.15 : 0.1), radius: isHovered && !isDisabled ? 4 : 2, y: 1)
                }
            }
            .rotation3DEffect(Angle.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isHovered && !isDisabled ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            #if os(macOS)
            .onHover { hovering in
                isHovered = hovering
            }
            #endif
        }
    }
}

#Preview {
    MemoryGameView()
}
