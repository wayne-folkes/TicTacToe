//
//  ContentView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/27/26.
//  Updated on 1/30/26 - Redesigned with TabView navigation
//  Updated on 2/01/26 - Added macOS NavigationSplitView support
//

import SwiftUI

enum GameType: String, CaseIterable {
    case ticTacToe = "Tic-Tac-Toe"
    case memory = "Memory Game"
    case dictionary = "Dictionary Game"
    case hangman = "Hangman"
}

enum AppSection: String, CaseIterable, Identifiable {
    case games = "Games"
    case stats = "Stats"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .games: return "gamecontroller.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Main app view with platform-specific navigation.
///
/// - iOS: Uses TabView with bottom tab bar (standard iOS pattern)
/// - macOS: Uses NavigationSplitView with sidebar (standard macOS pattern)
struct ContentView: View {
    #if os(macOS)
    @State private var selectedSection: AppSection = .games
    @State private var showKeyboardShortcuts = false
    #endif
    
    var body: some View {
        #if os(macOS)
        macOSView
            .sheet(isPresented: $showKeyboardShortcuts) {
                KeyboardShortcutsView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .showKeyboardShortcuts)) { _ in
                showKeyboardShortcuts = true
            }
        #else
        iOSView
        #endif
    }
    
    // MARK: - iOS View (TabView)
    #if !os(macOS)
    private var iOSView: some View {
        TabView {
            // Games Tab
            GamesGridView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            // Statistics Tab
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
    }
    #endif
    
    // MARK: - macOS View (NavigationSplitView)
    #if os(macOS)
    private var macOSView: some View {
        NavigationSplitView {
            // Sidebar
            List(AppSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("GOMP")
            .frame(minWidth: 200)
        } detail: {
            // Detail view based on selection
            detailView(for: selectedSection)
        }
    }
    
    @ViewBuilder
    private func detailView(for section: AppSection) -> some View {
        switch section {
        case .games:
            GamesGridView()
        case .stats:
            StatsView()
        case .settings:
            SettingsView()
        }
    }
    #endif
}

// MARK: - Keyboard Shortcuts View
#if os(macOS)
struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Shortcuts list
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    shortcutSection(title: "General", shortcuts: [
                        ("⌘N", "New Game"),
                        ("⌘⇧R", "Reset Statistics"),
                        ("⌘M", "Toggle Sound"),
                        ("⌘/", "Show Keyboard Shortcuts")
                    ])
                    
                    shortcutSection(title: "Navigation", shortcuts: [
                        ("⌘1", "Tic-Tac-Toe"),
                        ("⌘2", "Memory Game"),
                        ("⌘3", "Dictionary Game"),
                        ("⌘4", "Hangman")
                    ])
                    
                    shortcutSection(title: "Game Controls", shortcuts: [
                        ("1-4", "Dictionary: Select answer"),
                        ("1-9", "Tic-Tac-Toe: Select square"),
                        ("A-Z", "Hangman: Guess letter")
                    ])
                }
                .padding()
            }
        }
        .frame(width: 450, height: 500)
    }
    
    @ViewBuilder
    private func shortcutSection(title: String, shortcuts: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach(shortcuts, id: \.0) { shortcut in
                    HStack {
                        Text(shortcut.0)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(6)
                        
                        Text(shortcut.1)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
#endif

#Preview {
    ContentView()
}
