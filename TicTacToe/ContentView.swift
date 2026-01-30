//
//  ContentView.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/27/26.
//

import SwiftUI

enum GameType: String, CaseIterable {
    case ticTacToe = "Tic-Tac-Toe"
    case memory = "Memory Game"
    case dictionary = "Dictionary Game"
    case hangman = "Hangman"
}

struct ContentView: View {
    @State private var selectedGame: GameType = .ticTacToe
    @State private var showMenu = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main Content
            VStack(spacing: 0) {
                // Custom Header with Hamburger and Settings
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }
                .padding(.top, 50) // Adjust for safe area
                .zIndex(10)
                
                Spacer()
            }
            .zIndex(2)
            
            // Game View
            Group {
                switch selectedGame {
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
            .zIndex(1)
            .disabled(showMenu) // Disable interaction when menu is open
            //.offset(x: showMenu ? 250 : 0) // Optional slide
            
            // Sidebar Menu
            if showMenu {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                    .zIndex(3)
                
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Menu")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 50)
                            .foregroundColor(.white)
                        
                        ForEach(GameType.allCases, id: \.self) { game in
                            Button(action: {
                                selectedGame = game
                                withAnimation {
                                    showMenu = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: iconForGame(game))
                                    Text(game.rawValue)
                                        .font(.headline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(selectedGame == game ? Color.blue : Color.clear)
                                .cornerRadius(10)
                            }
                            .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white)
                            .padding(.vertical)
                        
                        Button(action: {
                            showSettings = true
                            withAnimation {
                                showMenu = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text("Settings")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cornerRadius(10)
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .edgesIgnoringSafeArea(.all)
                    .shadow(radius: 5)
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
                .zIndex(4)
            }
        }
        .ignoresSafeArea(.all, edges: .top) // Allow header to go up
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    func iconForGame(_ game: GameType) -> String {
        switch game {
        case .ticTacToe: return "gamecontroller"
        case .memory: return "brain.head.profile"
        case .dictionary: return "book.closed"
        case .hangman: return "figure.stand"
        }
    }
}

#Preview {
    ContentView()
}
