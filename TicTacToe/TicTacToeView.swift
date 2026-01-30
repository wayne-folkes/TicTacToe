//
//  TicTacToeView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/27/26.
//

import SwiftUI

struct TicTacToeView: View {
    @StateObject private var gameState = TicTacToeGameState()
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
                        CellView(player: gameState.board[index])
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
            .onDisappear {
                confettiTask?.cancel()
            }
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
    }
    
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.elevatedCardBackground)
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(player == .x ? .playerX : .playerO)
            }
        }
    }
}
