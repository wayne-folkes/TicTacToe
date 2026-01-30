import SwiftUI

struct SettingsView: View {
    @ObservedObject var statistics = GameStatistics.shared
    @State private var showResetAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Preferences Section
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $statistics.soundEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                            Text("Sound Effects")
                        }
                    }
                    
                    Toggle(isOn: $statistics.hapticsEnabled) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.purple)
                            Text("Haptic Feedback")
                        }
                    }
                }
                
                // MARK: - Statistics Section
                Section(header: Text("Overall Statistics")) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.green)
                        Text("Total Games Played")
                        Spacer()
                        Text("\(statistics.totalGamesPlayed)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Tic-Tac-Toe Statistics
                Section(header: Text("Tic-Tac-Toe")) {
                    StatRow(icon: "play.circle.fill", iconColor: .blue, label: "Games Played", value: "\(statistics.ticTacToeGamesPlayed)")
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, label: "X Wins", value: "\(statistics.ticTacToeXWins)")
                    StatRow(icon: "checkmark.circle.fill", iconColor: .orange, label: "O Wins", value: "\(statistics.ticTacToeOWins)")
                    StatRow(icon: "equal.circle.fill", iconColor: .gray, label: "Draws", value: "\(statistics.ticTacToeDraws)")
                    if statistics.ticTacToeGamesPlayed > 0 {
                        StatRow(icon: "chart.bar.fill", iconColor: .purple, label: "Win Rate", value: String(format: "%.1f%%", statistics.ticTacToeWinRate))
                    }
                }
                
                // MARK: - Memory Game Statistics
                Section(header: Text("Memory Game")) {
                    StatRow(icon: "play.circle.fill", iconColor: .blue, label: "Games Played", value: "\(statistics.memoryGamesPlayed)")
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, label: "Games Won", value: "\(statistics.memoryGamesWon)")
                    StatRow(icon: "star.fill", iconColor: .yellow, label: "High Score", value: "\(statistics.memoryHighScore)")
                    if statistics.memoryGamesPlayed > 0 {
                        StatRow(icon: "chart.bar.fill", iconColor: .purple, label: "Win Rate", value: String(format: "%.1f%%", statistics.memoryWinRate))
                    }
                }
                
                // MARK: - Dictionary Game Statistics
                Section(header: Text("Dictionary Game")) {
                    StatRow(icon: "play.circle.fill", iconColor: .blue, label: "Games Played", value: "\(statistics.dictionaryGamesPlayed)")
                    StatRow(icon: "star.fill", iconColor: .yellow, label: "High Score", value: "\(statistics.dictionaryHighScore)")
                }
                
                // MARK: - Hangman Statistics
                Section(header: Text("Hangman")) {
                    StatRow(icon: "play.circle.fill", iconColor: .blue, label: "Games Played", value: "\(statistics.hangmanGamesPlayed)")
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, label: "Games Won", value: "\(statistics.hangmanGamesWon)")
                    StatRow(icon: "xmark.circle.fill", iconColor: .red, label: "Games Lost", value: "\(statistics.hangmanGamesLost)")
                    StatRow(icon: "star.fill", iconColor: .yellow, label: "High Score", value: "\(statistics.hangmanHighScore)")
                    if statistics.hangmanGamesPlayed > 0 {
                        StatRow(icon: "chart.bar.fill", iconColor: .purple, label: "Win Rate", value: String(format: "%.1f%%", statistics.hangmanWinRate))
                    }
                }
                
                // MARK: - Actions Section
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Reset All Statistics")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/wayne-folkes/TicTacToe") ?? URL(string: "https://github.com")!) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.blue)
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundColor(.orange)
                        Text("Built with SwiftUI")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Statistics", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    statistics.resetAllStatistics()
                }
            } message: {
                Text("Are you sure you want to reset all game statistics? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Stat Row Component
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .bold()
        }
    }
}

#Preview {
    SettingsView()
}
