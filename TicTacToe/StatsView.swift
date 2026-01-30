//
//  StatsView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/30/26.
//

import SwiftUI

/// Statistics overview screen showing performance across all games.
///
/// This view follows Apple HIG with a grouped list style, proper hierarchy,
/// and semantic colors that adapt to light/dark mode.
struct StatsView: View {
    @ObservedObject private var stats = GameStatistics.shared
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Overview Section
                Section {
                    HStack {
                        Label("Total Games", systemImage: "gamecontroller.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(stats.totalGamesPlayed)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Overview")
                }
                
                // Tic-Tac-Toe Stats
                Section {
                    SimpleStatRow(label: "Games Played", value: "\(stats.ticTacToeGamesPlayed)")
                    SimpleStatRow(label: "X Wins", value: "\(stats.ticTacToeXWins)")
                    SimpleStatRow(label: "O Wins", value: "\(stats.ticTacToeOWins)")
                    SimpleStatRow(label: "Draws", value: "\(stats.ticTacToeDraws)")
                    SimpleStatRow(label: "Win Rate", value: String(format: "%.1f%%", stats.ticTacToeWinRate))
                } header: {
                    Label("Tic-Tac-Toe", systemImage: "xmark.circle.fill")
                        .foregroundColor(.blue)
                }
                
                // Memory Game Stats
                Section {
                    SimpleStatRow(label: "Games Played", value: "\(stats.memoryGamesPlayed)")
                    SimpleStatRow(label: "Games Won", value: "\(stats.memoryGamesWon)")
                    SimpleStatRow(label: "High Score", value: "\(stats.memoryHighScore)")
                    SimpleStatRow(label: "Win Rate", value: String(format: "%.1f%%", stats.memoryWinRate))
                } header: {
                    Label("Memory Game", systemImage: "brain.head.profile")
                        .foregroundColor(.purple)
                }
                
                // Dictionary Game Stats
                Section {
                    SimpleStatRow(label: "Games Played", value: "\(stats.dictionaryGamesPlayed)")
                    SimpleStatRow(label: "High Score", value: "\(stats.dictionaryHighScore)")
                } header: {
                    Label("Dictionary", systemImage: "book.closed.fill")
                        .foregroundColor(.green)
                }
                
                // Hangman Stats
                Section {
                    SimpleStatRow(label: "Games Played", value: "\(stats.hangmanGamesPlayed)")
                    SimpleStatRow(label: "Wins", value: "\(stats.hangmanGamesWon)")
                    SimpleStatRow(label: "Losses", value: "\(stats.hangmanGamesLost)")
                    SimpleStatRow(label: "High Score", value: "\(stats.hangmanHighScore)")
                    SimpleStatRow(label: "Win Rate", value: String(format: "%.1f%%", stats.hangmanWinRate))
                } header: {
                    Label("Hangman", systemImage: "figure.stand")
                        .foregroundColor(.orange)
                }
                
                // Reset Section
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset All Statistics")
                        }
                    }
                } footer: {
                    Text("This will permanently delete all game statistics. This action cannot be undone.")
                        .font(.caption)
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle("Statistics")
            .alert("Reset Statistics?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    stats.resetAllStatistics()
                }
            } message: {
                Text("Are you sure you want to reset all game statistics? This cannot be undone.")
            }
        }
    }
}

/// Reusable row component for displaying a statistic label and value.
private struct SimpleStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StatsView()
}
