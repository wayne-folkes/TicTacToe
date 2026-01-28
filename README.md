# Tic-Tac-Toe & Memory Game

A native iOS application built with SwiftUI, featuring two classic games in one app.

## Features

### ⭕️ Tic-Tac-Toe
- **2-Player Mode**: Classic Pass & Play functionality.
- **Dynamic Themes**: The background color shifts smoothly between turns (Blue/Cyan for X, Pink/Orange for O).
- **Celebration Effects**: Confetti animation upon winning.
- **Smart Status**: Indicates current turn, winner, or draw.

### 🧠 Memory Game
- **6x6 Grid**: A challenging board with 36 cards (18 pairs).
- **Emoji Theme**: Match pairs of cute animal emojis.
- **Score Tracking**: Points awarded for matches, deducted for mismatches.
- **Smooth Animations**: Card flipping and matching effects.

### 🧭 Navigation
- **Hamburger Menu**: Easily switch between games using the side menu.
- **Dark Mode Menu**: High-contrast menu for better visibility.

## Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)

## Requirements
- Xcode 15.0 or later
- iOS 17.0 or later

## How to Run
1. Clone this repository or download the source code.
2. Open `TicTacToe/TicTacToe.xcodeproj` in **Xcode**.
3. Select an iOS Simulator (e.g., iPhone 15) from the scheme selector.
4. Press **Cmd + R** to build and run the app.

## Project Structure
- `ContentView.swift`: Main entry point containing the navigation logic.
- `TicTacToeView.swift` & `TicTacToeGameState.swift`: Logic and UI for Tic-Tac-Toe.
- `MemoryGameView.swift` & `MemoryGameState.swift`: Logic and UI for the Memory Game.
