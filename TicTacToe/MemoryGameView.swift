import SwiftUI

struct MemoryGameView: View {
    @StateObject private var gameState = MemoryGameState()
    @ObservedObject private var sessionTracker = SessionTimeTracker.shared
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    @State private var shakeOffsets: [UUID: CGFloat] = [:]
    @State private var highlightedMismatchIds: Set<UUID> = []
    
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
            
            // Memory grid with responsive sizing to fit on screen
            GeometryReader { geometry in
                let availableHeight = geometry.size.height
                let availableWidth = geometry.size.width
                
                // Calculate optimal card size to fit 5 rows + spacing
                let horizontalPadding: CGFloat = 32 // 16 per side
                let spacing: CGFloat = 8
                let columns: CGFloat = 4
                let rows: CGFloat = 5
                
                let cardWidth = (availableWidth - horizontalPadding - (spacing * (columns - 1))) / columns
                let cardHeight = (availableHeight - (spacing * (rows - 1))) / rows
                
                // Use the limiting dimension to maintain aspect ratio
                let finalCardWidth = min(cardWidth, cardHeight * 2/3)
                let finalCardHeight = finalCardWidth * 3/2
                
                VStack(spacing: spacing) {
                    ForEach(0..<Int(rows), id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<Int(columns), id: \.self) { col in
                                let index = row * Int(columns) + col
                                if index < gameState.cards.count {
                                    let card = gameState.cards[index]
                                    CardView(
                                        card: card,
                                        isDisabled: gameState.isProcessingMismatch || card.isFaceUp || card.isMatched,
                                        isMismatched: highlightedMismatchIds.contains(card.id)
                                    )
                                    .frame(width: finalCardWidth, height: finalCardHeight)
                                    .offset(x: shakeOffsets[card.id] ?? 0)
                                    .onTapGesture {
                                        guard !gameState.isProcessingMismatch else { return }
                                        
                                        SoundManager.shared.play(.flip)
                                        HapticManager.shared.impact(style: .light)
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            gameState.choose(card)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .onChange(of: gameState.mismatchedCardIds) { _, ids in
                // Trigger shake animation and red highlight for mismatched cards
                guard !ids.isEmpty else {
                    highlightedMismatchIds = []
                    return
                }
                
                // Add to highlighted set for red glow
                highlightedMismatchIds = ids
                
                // Shake animation
                for cardId in ids {
                    withAnimation(.default.repeatCount(3).speed(6)) {
                        shakeOffsets[cardId] = 10
                    }
                    // Reset shake after animation completes
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.5))
                        shakeOffsets[cardId] = 0
                    }
                }
                
                // Remove highlight after mismatch delay
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.5))
                    highlightedMismatchIds = []
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
        .onAppear {
            sessionTracker.startSession(for: "Memory")
        }
        .onDisappear {
            confettiTask?.cancel()
            sessionTracker.endSession()
        }
    }
}

struct CardView: View {
    let card: MemoryCard
    let isDisabled: Bool
    let isMismatched: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if card.isFaceUp || card.isMatched {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.elevatedCardBackground)
                    
                    // Red border for mismatched cards, normal border otherwise
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isMismatched ? Color.errorColor : Color.memoryAccent, lineWidth: isMismatched ? 4 : 2)
                        
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
            // Add red glow for mismatched cards
            .shadow(color: isMismatched ? Color.errorColor.opacity(0.8) : .clear, radius: isMismatched ? 12 : 0)
            .animation(.easeInOut(duration: 0.2), value: isMismatched)
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
