import SwiftUI
import Charts

/// Statistics visualization screen with charts and trends.
///
/// Displays win rate over time, games played per day, and session duration analysis
/// using SwiftUI Charts framework.
struct StatisticsChartsView: View {
    @ObservedObject private var history = GameHistory.shared
    @ObservedObject private var stats = GameStatistics.shared
    
    @State private var selectedGame: String = "All Games"
    @State private var selectedPeriod: Int = 30  // days
    
    private let games = ["All Games", "TicTacToe", "Memory", "Dictionary", "Hangman"]
    private let periods = [7, 14, 30, 90]
    
    var body: some View {
        NavigationStack {
            List {
                // Filters Section
                Section {
                    Picker("Game", selection: $selectedGame) {
                        ForEach(games, id: \.self) { game in
                            Text(game == "All Games" ? "🎮 All Games" : gameDisplayName(game))
                                .tag(game)
                        }
                    }
                    
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                } header: {
                    Text("Filters")
                }
                
                // Win Rate Over Time Chart
                Section {
                    winRateChartView
                        .frame(height: 200)
                        .padding(.vertical, 8)
                } header: {
                    Text("Win Rate Trend")
                } footer: {
                    Text("Shows daily win percentage over the selected period")
                        .font(.caption)
                }
                
                // Games Played Chart
                Section {
                    gamesPlayedChartView
                        .frame(height: 200)
                        .padding(.vertical, 8)
                } header: {
                    Text("Games Per Day")
                } footer: {
                    Text("Number of games played each day")
                        .font(.caption)
                }
                
                // Play Time Distribution
                if selectedGame != "All Games" {
                    Section {
                        playTimeChartView
                            .frame(height: 180)
                            .padding(.vertical, 8)
                    } header: {
                        Text("Session Duration")
                    } footer: {
                        Text("Average session length over time")
                            .font(.caption)
                    }
                }
                
                // Summary Stats
                Section {
                    summaryStatsView
                } header: {
                    Text("Summary")
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle("Charts & Trends")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    // MARK: - Chart Views
    
    private var winRateChartView: some View {
        let gameFilter = selectedGame == "All Games" ? nil : selectedGame
        let data = history.dailyWinRates(for: gameFilter, lastDays: selectedPeriod)
        
        return Group {
            if data.isEmpty || data.allSatisfy({ $0.gamesPlayed == 0 }) {
                emptyChartPlaceholder(message: "No games played in this period")
            } else {
                Chart {
                    ForEach(data) { stat in
                        LineMark(
                            x: .value("Date", stat.date),
                            y: .value("Win Rate", stat.winRate)
                        )
                        .foregroundStyle(chartColor(for: selectedGame))
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", stat.date),
                            y: .value("Win Rate", stat.winRate)
                        )
                        .foregroundStyle(chartColor(for: selectedGame).opacity(0.1))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let number = value.as(Double.self) {
                                Text("\(Int(number))%")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: selectedPeriod > 30 ? 14 : 7)) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                        AxisGridLine()
                    }
                }
            }
        }
    }
    
    private var gamesPlayedChartView: some View {
        let gameFilter = selectedGame == "All Games" ? nil : selectedGame
        let data = history.dailyWinRates(for: gameFilter, lastDays: selectedPeriod)
        
        return Group {
            if data.isEmpty || data.allSatisfy({ $0.gamesPlayed == 0 }) {
                emptyChartPlaceholder(message: "No games played in this period")
            } else {
                Chart {
                    ForEach(data) { stat in
                        BarMark(
                            x: .value("Date", stat.date),
                            y: .value("Games", stat.gamesPlayed)
                        )
                        .foregroundStyle(chartColor(for: selectedGame).gradient)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: selectedPeriod > 30 ? 14 : 7)) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            }
        }
    }
    
    private var playTimeChartView: some View {
        let data = history.results(for: selectedGame)
            .prefix(20)
            .reversed()
        
        return Group {
            if data.isEmpty {
                emptyChartPlaceholder(message: "No session data available")
            } else {
                Chart {
                    ForEach(Array(data)) { result in
                        BarMark(
                            x: .value("Date", result.timestamp),
                            y: .value("Duration", result.duration / 60)  // Convert to minutes
                        )
                        .foregroundStyle(chartColor(for: selectedGame).gradient)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text("\(Int(minutes))m")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            }
        }
    }
    
    private var summaryStatsView: some View {
        let gameFilter = selectedGame == "All Games" ? nil : selectedGame
        let recentWinRate = history.winRate(for: gameFilter, lastDays: selectedPeriod)
        let totalGames = gameFilter == nil ? stats.totalGamesPlayed : gamesPlayed(for: selectedGame)
        
        return VStack(spacing: 0) {
            HStack {
                Text("Current Win Rate")
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: "%.1f%%", recentWinRate))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            HStack {
                Text("Total Games")
                    .foregroundColor(.primary)
                Spacer()
                Text("\(totalGames)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
            if gameFilter != nil {
                Divider()
                
                HStack {
                    Text("Total Play Time")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(GameStatistics.formatTime(totalTime(for: selectedGame)))
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func emptyChartPlaceholder(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func gameDisplayName(_ game: String) -> String {
        switch game {
        case "TicTacToe": return "⭕️ Tic-Tac-Toe"
        case "Memory": return "🧠 Memory"
        case "Dictionary": return "📖 Dictionary"
        case "Hangman": return "🎭 Hangman"
        default: return game
        }
    }
    
    private func chartColor(for game: String) -> Color {
        switch game {
        case "TicTacToe": return .blue
        case "Memory": return .purple
        case "Dictionary": return .green
        case "Hangman": return .orange
        default: return .accentColor
        }
    }
    
    private func gamesPlayed(for game: String) -> Int {
        switch game {
        case "TicTacToe": return stats.ticTacToeGamesPlayed
        case "Memory": return stats.memoryGamesPlayed
        case "Dictionary": return stats.dictionaryGamesPlayed
        case "Hangman": return stats.hangmanGamesPlayed
        default: return 0
        }
    }
    
    private func totalTime(for game: String) -> TimeInterval {
        switch game {
        case "TicTacToe": return stats.ticTacToeTotalTime
        case "Memory": return stats.memoryTotalTime
        case "Dictionary": return stats.dictionaryTotalTime
        case "Hangman": return stats.hangmanTotalTime
        default: return 0
        }
    }
}

#Preview {
    StatisticsChartsView()
}
