//
//  GamesGridView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/30/26.
//

import SwiftUI

/// Grid view displaying all available games in a card-based layout.
///
/// This view follows Apple HIG with a 2-column grid, native iOS styling,
/// and proper spacing using the 8pt grid system.
struct GamesGridView: View {
    @State private var selectedGame: GameType? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GameType.allCases, id: \.self) { game in
                        GameCard(gameType: game)
                            .onTapGesture {
                                HapticManager.shared.impact(style: .light)
                                SoundManager.shared.play(.tap)
                                selectedGame = game
                            }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Games")
            .navigationDestination(item: $selectedGame) { game in
                gameView(for: game)
            }
            #if os(macOS)
            .onReceive(NotificationCenter.default.publisher(for: .switchToGame)) { notification in
                if let gameType = notification.object as? GameType {
                    selectedGame = gameType
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .ticTacToe:
            TicTacToeView()
        case .memory:
            MemoryGameView()
        case .dictionary:
            DictionaryGameView()
        case .hangman:
            HangmanGameView()
        }
    }
}

/// Individual game card component following Apple HIG.
struct GameCard: View {
    let gameType: GameType
    @ObservedObject private var stats = GameStatistics.shared
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: iconForGame(gameType))
                .font(.system(size: 48, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accentColor(for: gameType))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            // Title
            Text(gameType.rawValue)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Stats
            Text(statsText(for: gameType))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        #if os(iOS)
        .background(Color(.secondarySystemBackground))
        #else
        .background(Color.gray.opacity(isHovered ? 0.15 : 0.1))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        #if os(iOS)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.tertiarySystemFill), lineWidth: 1)
        )
        #else
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        #endif
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
        #endif
    }
    
    private func iconForGame(_ game: GameType) -> String {
        switch game {
        case .ticTacToe: return "xmark.circle.fill"
        case .memory: return "brain.head.profile"
        case .dictionary: return "book.closed.fill"
        case .hangman: return "figure.stand"
        }
    }
    
    private func accentColor(for game: GameType) -> Color {
        switch game {
        case .ticTacToe: return .blue
        case .memory: return .purple
        case .dictionary: return .green
        case .hangman: return .orange
        }
    }
    
    private func statsText(for game: GameType) -> String {
        switch game {
        case .ticTacToe:
            return "\(stats.ticTacToeGamesPlayed) played"
        case .memory:
            return "\(stats.memoryGamesWon) wins"
        case .dictionary:
            return "High: \(stats.dictionaryHighScore)"
        case .hangman:
            return "\(stats.hangmanGamesWon) wins"
        }
    }
}

#Preview {
    GamesGridView()
}
