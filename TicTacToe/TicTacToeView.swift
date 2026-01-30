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
    
    var body: some View {
        ZStack {
            // Dynamic Background
            LinearGradient(gradient: Gradient(colors: gameState.currentPlayer == .x ? [Color.blue, Color.cyan] : [Color.pink, Color.orange]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 0.5), value: gameState.currentPlayer)
            
            VStack(spacing: 20) {
                Text("Tic Tac Toe")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text(statusText)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(0..<9) { index in
                        CellView(player: gameState.board[index])
                            .onTapGesture {
                                // Only provide haptic if move is valid
                                if gameState.board[index] == nil && gameState.winner == nil && !gameState.isDraw {
                                    HapticManager.shared.impact(style: .medium)
                                }
                                gameState.makeMove(at: index)
                            }
                    }
                }
                .padding()
                
                Button(action: {
                    showConfetti = false
                    gameState.resetGame()
                }) {
                    Text("Restart Game")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(gameState.currentPlayer == .x ? .blue : .pink)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .opacity(gameState.winner != nil || gameState.isDraw ? 1.0 : 0.0)
            }
            .padding()
            .padding(.top, 50)
            .onChange(of: gameState.winner) { _, newValue in
                if newValue != nil {
                    HapticManager.shared.notification(type: .success)
                    withAnimation(.easeIn(duration: 0.3)) {
                        showConfetti = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showConfetti = false
                        }
                    }
                }
            }
            .onChange(of: gameState.isDraw) { _, newValue in
                if newValue {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showConfetti = false
                    }
                }
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.cardBackground)
                .aspectRatio(1.0, contentMode: .fit)
                .shadow(radius: 2)
            
            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(player == .x ? .blue : .pink)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.3) : .white, radius: 1)
            }
        }
    }
}
