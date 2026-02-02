//
//  GOMPApp.swift
//  Games on my phone (GOMP)
//
//  Created by Wayne Folkes on 1/27/26.
//  Updated on 2/01/26 - Added macOS window management and keyboard shortcuts
//

import SwiftUI

@main
struct GOMPApp: App {
    var body: some Scene {
        WindowGroup("GOMP") {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity,
                       minHeight: 600, idealHeight: 800, maxHeight: .infinity)
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            macOSCommands()
        }
        #endif
    }
    
    #if os(macOS)
    @CommandsBuilder
    private func macOSCommands() -> some Commands {
        // Replace default "New" command
        CommandGroup(replacing: .newItem) {
            Button("New Game") {
                NotificationCenter.default.post(name: .newGame, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        
        // Custom Game menu
        CommandMenu("Game") {
            Button("Reset Statistics...") {
                NotificationCenter.default.post(name: .resetStats, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Tic-Tac-Toe") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.ticTacToe)
            }
            .keyboardShortcut("1", modifiers: .command)
            
            Button("Memory Game") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.memory)
            }
            .keyboardShortcut("2", modifiers: .command)
            
            Button("Dictionary") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.dictionary)
            }
            .keyboardShortcut("3", modifiers: .command)
            
            Button("Hangman") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.hangman)
            }
            .keyboardShortcut("4", modifiers: .command)
            
            Button("2048") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.twentyFortyEight)
            }
            .keyboardShortcut("5", modifiers: .command)
            
            Button("Math Quiz") {
                NotificationCenter.default.post(name: .switchToGame, object: GameType.mathQuiz)
            }
            .keyboardShortcut("6", modifiers: .command)
            
            Divider()
            
            Button("Toggle Sound") {
                NotificationCenter.default.post(name: .toggleSound, object: nil)
            }
            .keyboardShortcut("m", modifiers: .command)
        }
        
        // Help menu with keyboard shortcuts
        CommandGroup(replacing: .help) {
            Button("Keyboard Shortcuts") {
                NotificationCenter.default.post(name: .showKeyboardShortcuts, object: nil)
            }
            .keyboardShortcut("/", modifiers: .command)
        }
    }
    #endif
}
