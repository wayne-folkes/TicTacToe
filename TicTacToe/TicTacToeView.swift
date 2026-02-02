//
//  TicTacToeView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/27/26.
//

import SwiftUI

struct TicTacToeView: View {
    @StateObject private var gameState = TicTacToeGameState()
    @ObservedObject private var sessionTracker = SessionTimeTracker.shared
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Color.cardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Game Mode Picker
                Picker("Mode", selection: $gameState.gameMode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode == .twoPlayer ? "👤 vs 👤" : "👤 vs 🤖").tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .onChange(of: gameState.gameMode) { _, mode in
                    gameState.changeGameMode(mode)
                }
                
                // Difficulty Picker (only for AI mode)
                if gameState.gameMode == .vsAI {
                    Picker("Difficulty", selection: $gameState.aiDifficulty) {
                        ForEach(AIDifficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .onChange(of: gameState.aiDifficulty) { _, difficulty in
                        gameState.changeAIDifficulty(difficulty)
                    }
                }
                
                // Header
                VStack(spacing: 8) {
                    Text(gameState.isAIThinking ? "AI Thinking..." : "Tic Tac Toe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(statusText)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(0..<9) { index in
                        CellView(
                            player: gameState.board[index],
                            isDisabled: gameState.isAIThinking || gameState.board[index] != nil || gameState.winner != nil || gameState.isDraw
                        )
                        .onTapGesture {
                            // Play sound and haptic if move is valid
                            if !gameState.isAIThinking && gameState.board[index] == nil && gameState.winner == nil && !gameState.isDraw {
                                SoundManager.shared.play(.tap)
                                HapticManager.shared.impact(style: .medium)
                            }
                            gameState.makeMove(at: index)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Game Over View
                if gameState.winner != nil || gameState.isDraw {
                    GameOverView(
                        message: statusText,
                        isSuccess: gameState.winner != nil,
                        onPlayAgain: {
                            confettiTask?.cancel()
                            showConfetti = false
                            gameState.resetGame()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .padding(.vertical, 8)
            .onChange(of: gameState.winner) { _, newValue in
                if newValue != nil {
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
            .onChange(of: gameState.isDraw) { _, newValue in
                if newValue {
                    SoundManager.shared.play(.lose)
                    withAnimation(.easeIn(duration: 0.3)) {
                        showConfetti = false
                    }
                }
            }
            .onAppear {
                sessionTracker.startSession(for: "TicTacToe")
            }
            .onDisappear {
                confettiTask?.cancel()
                sessionTracker.endSession()
            }
            #if os(macOS)
            .focusable()
            .onKeyPress { press in
                handleKeyPress(press)
            }
            #endif
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
    }
    
    #if os(macOS)
    /// Handles keyboard input on macOS for making moves
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Number keys 1-9 or numpad 1-9 to select squares
        guard let number = Int(press.characters),
              (1...9).contains(number) else {
            return .ignored
        }
        
        // Convert to board index (1-9 becomes 0-8)
        let index = number - 1
        
        // Ignore if game over, not player's turn, or square occupied
        guard gameState.winner == nil,
              !gameState.isDraw,
              gameState.board[index] == nil,
              !gameState.isAIThinking else {
            return .ignored
        }
        
        // Make the move
        gameState.makeMove(at: index)
        
        return .handled
    }
    #endif
    
    var statusText: String {
        if let winner = gameState.winner {
            if gameState.gameMode == .vsAI {
                return winner == .x ? "🎉 You Win!" : "😔 AI Wins!"
            } else {
                return "🎉 Player \(winner.rawValue) Wins!"
            }
        } else if gameState.isDraw {
            return "🤝 It's a Draw!"
        } else if gameState.isAIThinking {
            return "⏳ AI is thinking..."
        } else if gameState.gameMode == .vsAI {
            return gameState.currentPlayer == .x ? "Your Turn (X)" : "AI's Turn (O)"
        } else {
            return "Player \(gameState.currentPlayer.rawValue)'s Turn"
        }
    }
}

struct CellView: View {
    let player: Player?
    let isDisabled: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
                .shadow(color: .black.opacity(isHovered && !isDisabled ? 0.1 : 0.05), radius: isHovered && !isDisabled ? 4 : 2, y: 1)
                .scaleEffect(isHovered && !isDisabled ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
            
            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(player == .x ? .playerX : .playerO)
            }
        }
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
        #endif
    }
    
    private var backgroundColor: Color {
        #if os(macOS)
        if isHovered && !isDisabled {
            return Color.elevatedCardBackground.opacity(0.9)
        }
        #endif
        return Color.elevatedCardBackground
    }
}
