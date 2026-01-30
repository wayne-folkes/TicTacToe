//
//  ContentView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/27/26.
//  Updated on 1/30/26 - Redesigned with TabView navigation
//

import SwiftUI

enum GameType: String, CaseIterable {
    case ticTacToe = "Tic-Tac-Toe"
    case memory = "Memory Game"
    case dictionary = "Dictionary Game"
    case hangman = "Hangman"
}

/// Main app view with TabView navigation following Apple HIG.
///
/// This view replaces the previous hamburger menu with a standard iOS TabView,
/// providing three main sections: Games, Statistics, and Settings.
struct ContentView: View {
    var body: some View {
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
        .tint(.blue) // Primary tint color for tab selection
    }
}

#Preview {
    ContentView()
}
