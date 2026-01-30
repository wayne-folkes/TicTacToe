# Multi-Game iOS App 🎮

A native iOS application built with SwiftUI, featuring four engaging games in one beautiful app.

[![iOS](https://img.shields.io/badge/iOS-26.2%2B-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)](https://developer.apple.com/xcode/swiftui/)

## 🎯 Features

### ⭕️ Tic-Tac-Toe
- **2-Player Mode**: Classic Pass & Play functionality
- **Dynamic Themes**: Background color shifts smoothly between turns (Blue/Cyan for X, Pink/Orange for O)
- **Celebration Effects**: Confetti animation upon winning
- **Smart Status**: Indicates current turn, winner, or draw
- **Reset Functionality**: Start a new game anytime

### 🧠 Memory Game
- **4x6 Grid**: 24 cards (12 pairs) for optimal challenge
- **Multiple Themes**: 
  - 🐾 Animals (Cat, Dog, Bear, Lion, etc.)
  - 👥 People (various emoji faces)
- **Score Tracking**: Points awarded for matches, deducted for mismatches
- **Smooth Animations**: Card flipping and matching effects
- **Confetti Celebration**: Win animation when all pairs are matched

### 📖 Dictionary Game
- **Multiple Difficulty Levels**:
  - Easy: Common, simple words
  - Medium (Default): Moderately challenging vocabulary
  - Hard: Advanced words fetched from live API
- **API Integration**: 
  - Random word generation via [random-word-api](https://random-word-api.herokuapp.com/)
  - Definitions from [Dictionary API](https://dictionaryapi.dev/)
- **Interactive Quiz**: Choose the correct definition from 4 options
- **Score Tracking**: Earn points for correct answers
- **Smart Timer**: 10-second countdown with automatic progression
- **Hint System**: Displays correct answer after selection
- **Fallback Mode**: Uses local word bank if API is unavailable

### 🎭 Hangman
- **Traditional Stick Figure**: Classic 8-stage progressive drawing
  - Gallows, head, body, left arm, right arm, left leg, right leg, sad face
- **Word Categories**:
  - 🦁 Animals
  - 🍕 Food
  - ⚽️ Sports
  - 🎨 Colors
  - 🌍 Countries
- **Smart Word Selection**: All words limited to 8 letters or less
- **8 Wrong Guesses**: More forgiving than traditional 6-guess limit
- **Full Keyboard**: A-Z letter buttons with visual feedback
  - Green: Correct guess
  - Red: Wrong guess
  - Blue: Available
- **Statistics Tracking**: 
  - Total score
  - Games won
  - Games lost
- **Confetti Celebration**: Animated confetti on winning

## 🧭 Navigation
- **Hamburger Menu**: Easily switch between games using the elegant side menu
- **Dark Mode Menu**: High-contrast menu with game icons for better visibility
- **Smooth Transitions**: Animated menu sliding and game switching

## 🎨 Design
- **Custom App Icon**: Playful burger emoji 🍔 on white background
- **Gradient Backgrounds**: Beautiful color gradients for each game
- **Consistent UI**: Unified design language across all games
- **Adaptive Layout**: Proper spacing to avoid status bar overlap
- **Confetti Component**: Reusable celebration animation shared across games

## 🏗️ Tech Stack
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Networking**: URLSession for API calls
- **Testing**: XCTest with comprehensive unit tests
- **CI/CD**: GitHub Actions for automated testing

## 📋 Requirements
- Xcode 16.4 or later
- iOS 26.2 or later
- macOS 14.0+ (for development)

## 🚀 How to Run

### Using Xcode
1. Clone this repository:
   ```bash
   git clone https://github.com/wayne-folkes/TicTacToe.git
   cd TicTacToe
   ```

2. Open `TicTacToe/TicTacToe.xcodeproj` in **Xcode**

3. Select an iOS Simulator (e.g., iPhone 16 Pro) from the scheme selector

4. Press **Cmd + R** to build and run the app

### Using Command Line
```bash
cd TicTacToe
xcodebuild -project TicTacToe.xcodeproj -scheme TicTacToe -sdk iphonesimulator build
```

### Running Tests
```bash
cd TicTacToe
swift test
```

## 📁 Project Structure

```
TicTacToe/
├── TicTacToe/
│   ├── TicTacToeApp.swift          # App entry point
│   ├── ContentView.swift           # Main navigation & hamburger menu
│   ├── TicTacToeView.swift         # Tic-Tac-Toe UI
│   ├── TicTacToeGameState.swift    # Tic-Tac-Toe game logic
│   ├── MemoryGameView.swift        # Memory game UI
│   ├── MemoryGameState.swift       # Memory game logic
│   ├── DictionaryGameView.swift    # Dictionary game UI
│   ├── DictionaryGameState.swift   # Dictionary game logic & API
│   ├── HangmanGameView.swift       # Hangman UI with stick figure
│   ├── HangmanGameState.swift      # Hangman game logic
│   ├── ConfettiView.swift          # Shared confetti animation
│   ├── CountdownButton.swift       # Timer button component
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/     # Custom burger emoji icon
├── Tests/
│   ├── DictionaryGameTests.swift   # Dictionary game tests
│   └── HangmanGameTests.swift      # Hangman game tests
├── Package.swift                    # SwiftPM configuration
└── README.md                        # This file
```

## 🧪 Testing
The project includes comprehensive unit tests:
- **DictionaryGameState**: Tests for initialization, API handling, and game logic
- **HangmanGameState**: Tests for word selection, guessing logic, win/loss conditions, and category changes

All tests are run automatically via GitHub Actions on every push.

## 🤝 Contributing
This is a personal learning project, but suggestions and feedback are welcome!

## 📝 License
This project is open source and available under the MIT License.

## 🙏 Acknowledgments
- Dictionary definitions powered by [Dictionary API](https://dictionaryapi.dev/)
- Random words from [Random Word API](https://random-word-api.herokuapp.com/)
- Built with ❤️ using SwiftUI

## 📱 Screenshots
*Coming soon*

---

**Made with SwiftUI** | **2026**
