import SwiftUI

/// Settings screen for app preferences.
///
/// Updated to work within TabView navigation following Apple HIG.
struct SettingsView: View {
    private let statistics = GameStatistics.shared
    @State private var soundEnabled: Bool
    @State private var hapticsEnabled: Bool
    
    init() {
        _soundEnabled = State(initialValue: GameStatistics.shared.soundEnabled)
        _hapticsEnabled = State(initialValue: GameStatistics.shared.hapticsEnabled)
    }
    @State private var showResetAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Preferences Section
                Section {
                    Toggle(isOn: $soundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                    }
                    .tint(.blue)
                    .onChange(of: soundEnabled) { _, newValue in
                        statistics.soundEnabled = newValue
                    }
                    
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptic Feedback", systemImage: "hand.tap.fill")
                    }
                    .tint(.blue)
                    .onChange(of: hapticsEnabled) { _, newValue in
                        statistics.hapticsEnabled = newValue
                    }
                } header: {
                    Text("Preferences")
                }
                
                // MARK: - Actions Section
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Statistics", systemImage: "arrow.clockwise")
                    }
                } footer: {
                    Text("This will permanently delete all game statistics. This action cannot be undone.")
                        .font(.caption)
                }
                
                // MARK: - About Section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/wayne-folkes/TicTacToe") ?? URL(string: "https://github.com")!) {
                        HStack {
                            Label("GitHub Repository", systemImage: "link.circle.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Label("Built with SwiftUI", systemImage: "hammer.fill")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle("Settings")
            .alert("Reset Statistics?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    statistics.resetAllStatistics()
                }
            } message: {
                Text("Are you sure you want to reset all game statistics? This cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
