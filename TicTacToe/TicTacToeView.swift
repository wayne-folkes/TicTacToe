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
            // Clean background following Apple HIG
            Color.cardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Tic Tac Toe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(statusText)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(0..<9) { index in
                        CellView(player: gameState.board[index])
                            .onTapGesture {
                                // Play sound and haptic if move is valid
                                if gameState.board[index] == nil && gameState.winner == nil && !gameState.isDraw {
                                    SoundManager.shared.play(.tap)
                                    HapticManager.shared.impact(style: .medium)
                                }
                                gameState.makeMove(at: index)
                            }
                    }
                }
                .padding()
                
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
                    .padding(.horizontal)
                }
            }
            .padding()
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
            return "\(winner.rawValue) Wins!"
        } else if gameState.isDraw {
            return "It's a Draw!"
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
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(player == .x ? .playerX : .playerO)
            }
        }
    }
}
