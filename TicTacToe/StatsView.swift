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
    @ObservedObject private var sessionTracker = SessionTimeTracker.shared
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
                    
                    HStack {
                        Label("Total Play Time", systemImage: "clock.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(GameStatistics.formatTime(stats.totalPlayTime))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if sessionTracker.isActive, let currentGame = sessionTracker.currentGame {
                        HStack {
                            Label("Current Session", systemImage: "timer")
                                .foregroundColor(.green)
                            Spacer()
                            Text("\(currentGame): \(sessionTracker.formattedElapsedTime)")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Charts navigation
                    NavigationLink {
                        StatisticsChartsView()
                    } label: {
                        Label("View Charts & Trends", systemImage: "chart.xyaxis.line")
                            .foregroundColor(.accentColor)
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
                    SimpleStatRow(label: "Total Time", value: GameStatistics.formatTime(stats.ticTacToeTotalTime))
                    SimpleStatRow(label: "Avg Session", value: GameStatistics.formatTime(stats.averageSessionDuration(for: "TicTacToe")))
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
                    SimpleStatRow(label: "Total Time", value: GameStatistics.formatTime(stats.memoryTotalTime))
                    SimpleStatRow(label: "Avg Session", value: GameStatistics.formatTime(stats.averageSessionDuration(for: "Memory")))
                } header: {
                    Label("Memory Game", systemImage: "brain.head.profile")
                        .foregroundColor(.purple)
                }
                
                // Dictionary Game Stats
                Section {
                    SimpleStatRow(label: "Games Played", value: "\(stats.dictionaryGamesPlayed)")
                    SimpleStatRow(label: "High Score", value: "\(stats.dictionaryHighScore)")
                    SimpleStatRow(label: "Total Time", value: GameStatistics.formatTime(stats.dictionaryTotalTime))
                    SimpleStatRow(label: "Avg Session", value: GameStatistics.formatTime(stats.averageSessionDuration(for: "Dictionary")))
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
                    SimpleStatRow(label: "Total Time", value: GameStatistics.formatTime(stats.hangmanTotalTime))
                    SimpleStatRow(label: "Avg Session", value: GameStatistics.formatTime(stats.averageSessionDuration(for: "Hangman")))
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
