# 🤝 Contributing Guide

Thank you for your interest in contributing to this iOS Game App! This guide will help you get started with development, whether you're fixing bugs, adding features, or creating new games.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Project Structure](#project-structure)
4. [How to Add a New Game](#how-to-add-a-new-game)
5. [Code Style Guide](#code-style-guide)
6. [Testing](#testing)
7. [Commit Guidelines](#commit-guidelines)
8. [Pull Request Process](#pull-request-process)

---

## Getting Started

### Prerequisites

- **macOS**: 14.0 or later
- **Xcode**: 16.4 or later
- **Swift**: 6.0 (included with Xcode)
- **Git**: For version control

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/wayne-folkes/TicTacToe.git
cd TicTacToe

# 2. Open in Xcode
open TicTacToe/TicTacToe.xcodeproj

# 3. Select a simulator (e.g., iPhone 16 Pro)
# 4. Press Cmd+R to build and run

# 5. Run tests
cd TicTacToe
swift test
```

---

## Development Setup

### Using Xcode (Recommended)

1. **Open Project**: `TicTacToe/TicTacToe.xcodeproj`
2. **Select Scheme**: Choose "TicTacToe" scheme
3. **Select Simulator**: Pick an iOS device (iPhone 16 Pro recommended)
4. **Build**: Cmd+B
5. **Run**: Cmd+R
6. **Test**: Cmd+U

### Using Command Line

```bash
# Build
cd TicTacToe
xcodebuild -project TicTacToe.xcodeproj -scheme TicTacToe -sdk iphonesimulator build

# Run tests (uses SwiftPM)
swift test

# Clean build
xcodebuild clean
```

### Recommended Xcode Settings

- **Editor → Show Invisibles**: See whitespace and tabs
- **Editor → Trim Trailing Whitespace**: Keep files clean
- **Preferences → Text Editing → Indent using**: Spaces (4 spaces)
- **Preferences → Source Control**: Enable Git

---

## Project Structure

```
TicTacToe/
├── TicTacToe/                      # Source code
│   ├── TicTacToeApp.swift          # App entry point
│   ├── ContentView.swift           # Main navigation
│   │
│   ├── [Game]View.swift            # UI for each game
│   ├── [Game]GameState.swift      # Logic for each game
│   │
│   ├── GameStatistics.swift        # Persistence manager
│   ├── SoundManager.swift          # Audio manager
│   ├── HapticManager.swift         # Haptic manager
│   │
│   ├── GameHeaderView.swift        # Shared components
│   ├── GameOverView.swift
│   ├── StatsCardView.swift
│   ├── ConfettiView.swift
│   ├── CountdownButton.swift
│   │
│   └── SettingsView.swift          # Settings screen
│
├── Tests/                          # Unit tests
│   └── [Game]GameStateTests.swift
│
├── ARCHITECTURE.md                 # Architecture docs
├── CONTRIBUTING.md                 # This file
├── TESTING.md                      # Testing guide
├── API.md                          # API documentation
└── README.md                       # User documentation
```

### Key Files

| File | Purpose | Lines |
|------|---------|-------|
| `ContentView.swift` | Navigation hub, menu, game switching | ~200 |
| `GameStatistics.swift` | Persistent storage for all games | ~270 |
| `TicTacToeGameState.swift` | Tic-Tac-Toe game logic | ~110 |
| `MemoryGameState.swift` | Memory card matching logic | ~150 |
| `DictionaryGameState.swift` | Dictionary quiz with API | ~290 |
| `HangmanGameState.swift` | Hangman word guessing logic | ~210 |

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed explanations.

---

## How to Add a New Game

Follow this step-by-step guide to add a 5th game to the app.

### Step 1: Create the Game State (Logic)

Create `TicTacToe/TicTacToe/[YourGame]GameState.swift`:

```swift
import SwiftUI
import Combine

/// Game logic for [YourGame]
@MainActor
class YourGameState: ObservableObject {
    // Published properties (SwiftUI watches these)
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    
    // Game-specific state
    @Published var yourGameData: [String] = []
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        isGameOver = false
        yourGameData = generateInitialData()
    }
    
    func playerAction() {
        // Game logic here
        checkForWin()
    }
    
    private func checkForWin() {
        if /* win condition */ {
            isGameOver = true
            GameStatistics.shared.recordYourGame(score: score)
        }
    }
    
    private func generateInitialData() -> [String] {
        // Initialize game data
        return []
    }
}
```

**Key Requirements**:
- Mark class `@MainActor` (required for GameStatistics access)
- Conform to `ObservableObject`
- Use `@Published` for all UI-visible state
- Call `GameStatistics.shared.recordXXXGame()` when game ends

### Step 2: Create the Game View (UI)

Create `TicTacToe/TicTacToe/[YourGame]View.swift`:

```swift
import SwiftUI

/// UI for [YourGame]
struct YourGameView: View {
    @StateObject private var gameState = YourGameState()
    @State private var showConfetti = false
    @State private var confettiTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Use shared header component
                GameHeaderView(
                    title: "Your Game",
                    score: gameState.score,
                    statusText: gameState.isGameOver ? "Game Over" : "Playing"
                )
                
                // Your game-specific UI
                gameBoard
                
                // Controls
                Button("Reset") {
                    SoundManager.shared.play(.click)
                    HapticManager.shared.impact(style: .medium)
                    gameState.startNewGame()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                // Use shared game over component
                if gameState.isGameOver {
                    GameOverView(
                        message: "🎉 Great job!",
                        isSuccess: true,
                        onPlayAgain: {
                            gameState.startNewGame()
                        }
                    )
                }
            }
            .padding()
            
            // Victory animation
            if showConfetti {
                ConfettiView()
            }
        }
        .onDisappear {
            confettiTask?.cancel()
        }
    }
    
    private var gameBoard: some View {
        // Your game UI here
        Text("Game Board")
    }
    
    private func triggerConfetti() {
        showConfetti = true
        
        confettiTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            showConfetti = false
        }
    }
}

#Preview {
    YourGameView()
}
```

**Key Requirements**:
- Use `@StateObject` for the game state
- Reuse shared components: `GameHeaderView`, `GameOverView`, `StatsCardView`
- Call `SoundManager.shared.play()` for audio
- Call `HapticManager.shared.impact()` for haptics
- Handle task cancellation in `onDisappear`

### Step 3: Add to GameStatistics

Edit `TicTacToe/TicTacToe/GameStatistics.swift`:

```swift
// 1. Add keys
private enum Keys {
    // ... existing keys ...
    static let yourGameGamesPlayed = "yourGameGamesPlayed"
    static let yourGameHighScore = "yourGameHighScore"
}

// 2. Add @Published properties
@Published var yourGameGamesPlayed: Int
@Published var yourGameHighScore: Int

// 3. Add computed property
var yourGameWinRate: Double {
    guard yourGameGamesPlayed > 0 else { return 0 }
    // Calculate win rate
    return 0.0
}

// 4. Load in init()
init() {
    // ... existing loads ...
    self.yourGameGamesPlayed = userDefaults.integer(forKey: Keys.yourGameGamesPlayed)
    self.yourGameHighScore = userDefaults.integer(forKey: Keys.yourGameHighScore)
}

// 5. Add record method
func recordYourGame(score: Int) {
    yourGameGamesPlayed += 1
    
    if score > yourGameHighScore {
        yourGameHighScore = score
    }
    
    saveToUserDefaults()
}

// 6. Update saveToUserDefaults()
private func saveToUserDefaults() {
    // ... existing saves ...
    userDefaults.set(yourGameGamesPlayed, forKey: Keys.yourGameGamesPlayed)
    userDefaults.set(yourGameHighScore, forKey: Keys.yourGameHighScore)
}

// 7. Update resetAllStatistics()
func resetAllStatistics() {
    // ... existing resets ...
    yourGameGamesPlayed = 0
    yourGameHighScore = 0
    
    saveToUserDefaults()
}

// 8. Update totalGamesPlayed
var totalGamesPlayed: Int {
    ticTacToeGamesPlayed + memoryGamesPlayed + 
    dictionaryGamesPlayed + hangmanGamesPlayed + 
    yourGameGamesPlayed  // Add this
}
```

### Step 4: Add to ContentView Navigation

Edit `TicTacToe/TicTacToe/ContentView.swift`:

```swift
// 1. Add to GameType enum
enum GameType: String, CaseIterable {
    case ticTacToe = "Tic Tac Toe"
    case memory = "Memory Game"
    case dictionary = "Dictionary"
    case hangman = "Hangman"
    case yourGame = "Your Game"  // Add this
}

// 2. Create @StateObject
struct ContentView: View {
    // ... existing state objects ...
    @StateObject private var yourGameState = YourGameState()
    
    // ... rest of code ...
}

// 3. Add to menu items
private var menuItems: some View {
    VStack(alignment: .leading, spacing: 20) {
        // ... existing menu items ...
        
        menuButton(
            title: "🎮 Your Game",
            gameType: .yourGame
        )
    }
}

// 4. Add to currentGameView switch
@ViewBuilder
private var currentGameView: some View {
    switch selectedGame {
    // ... existing cases ...
    case .yourGame:
        YourGameView()
            .environmentObject(yourGameState)
    }
}
```

### Step 5: Add to SettingsView Statistics

Edit `TicTacToe/TicTacToe/SettingsView.swift`:

```swift
private var statisticsSection: some View {
    VStack(spacing: 15) {
        // ... existing StatsCardViews ...
        
        StatsCardView(
            title: "Your Game",
            items: [
                ("Games Played", "\(stats.yourGameGamesPlayed)"),
                ("High Score", "\(stats.yourGameHighScore)")
            ]
        )
    }
}
```

### Step 6: Write Tests

Create `TicTacToe/Tests/[YourGame]Tests.swift`:

```swift
import XCTest
@testable import GamesApp

@MainActor
final class YourGameTests: XCTestCase {
    var gameState: YourGameState!
    
    override func setUp() {
        super.setUp()
        gameState = YourGameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(gameState.score, 0)
        XCTAssertFalse(gameState.isGameOver)
    }
    
    func testGameLogic() {
        // Test your game logic
        gameState.playerAction()
        XCTAssertTrue(/* some condition */)
    }
    
    func testWinCondition() {
        // Simulate winning
        // ... actions ...
        XCTAssertTrue(gameState.isGameOver)
    }
}
```

**Test Requirements**:
- Mark test class `@MainActor`
- Use `setUp()` and `tearDown()` for clean state
- Test initialization, game logic, win/loss conditions
- Aim for 70%+ code coverage

### Step 7: Run Tests

```bash
cd TicTacToe
swift test

# Should see:
# Test Suite 'All tests' passed
# Executed XX tests, with 0 failures
```

### Step 8: Update Documentation

Update these files:

1. **README.md**: Add game description, features
2. **ARCHITECTURE.md**: Mention new game in component list
3. **TESTING.md**: Add test count update

---

## Code Style Guide

### Swift Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

#### Naming

```swift
// ✅ Good: Clear, descriptive names
func calculateWinRate(gamesPlayed: Int, gamesWon: Int) -> Double { ... }
var currentPlayer: Player
let maxWrongGuesses = 8

// ❌ Bad: Unclear abbreviations
func calc(g: Int, w: Int) -> Double { ... }
var p: Player
let max = 8
```

#### Classes & Structs

```swift
// Use @MainActor for SwiftUI-related classes
@MainActor
class GameState: ObservableObject {
    @Published var score: Int = 0  // Use property observers sparingly
}

// Use structs for data models
struct Card: Identifiable, Equatable {
    let id = UUID()
    let content: String
}
```

#### Functions

```swift
// Document public APIs
/// Process a player's move and update game state.
///
/// - Parameter index: The board position (0-8)
/// - Returns: Whether the move was valid
func makeMove(at index: Int) -> Bool {
    guard isValidMove(index) else { return false }
    // ... implementation
    return true
}
```

#### Access Control

```swift
// Be explicit about access levels
public class GameManager { }        // Rarely needed
internal class GameState { }        // Default for most classes
private func helperMethod() { }     // Implementation details
```

### SwiftUI Style

```swift
// Extract complex views into computed properties
var body: some View {
    VStack {
        headerSection
        gameBoard
        controlsSection
    }
}

private var headerSection: some View {
    GameHeaderView(title: "Game", score: score)
}

// Use @ViewBuilder for conditional views
@ViewBuilder
private var gameStatus: some View {
    if isGameOver {
        GameOverView(message: "Done!", isSuccess: true, onPlayAgain: reset)
    }
}
```

### Documentation Comments

Use Swift's documentation markup:

```swift
/// Brief one-line summary.
///
/// Longer description with details about what this does
/// and why it exists.
///
/// - Parameters:
///   - first: Description of first parameter
///   - second: Description of second parameter
/// - Returns: Description of return value
/// - Throws: Description of errors (if applicable)
///
/// Example:
/// ```swift
/// let result = myFunction(first: 10, second: 20)
/// print(result) // 30
/// ```
func myFunction(first: Int, second: Int) -> Int {
    return first + second
}
```

### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Aim for 100 characters max
- **Braces**: Opening brace on same line
- **Spacing**: One blank line between methods
- **Imports**: Group and sort (Foundation, SwiftUI, Combine, etc.)

```swift
// ✅ Good formatting
func processMove(at index: Int) {
    guard isValid(index) else { return }
    
    updateBoard(at: index)
    checkWinCondition()
}

// ❌ Bad formatting
func processMove(at index: Int){
guard isValid(index) else{return}
updateBoard(at: index);checkWinCondition()
}
```

---

## Testing

### Running Tests

```bash
# Run all tests
cd TicTacToe
swift test

# Run tests in Xcode
# Cmd+U or Product → Test
```

### Writing Tests

See [TESTING.md](TESTING.md) for comprehensive guide.

Quick checklist:
- [ ] Mark test class `@MainActor`
- [ ] Test initialization
- [ ] Test game logic
- [ ] Test win/loss conditions
- [ ] Test edge cases (empty state, full board, etc.)
- [ ] Aim for 70%+ coverage

---

## Commit Guidelines

### Commit Message Format

```
<type>: <subject>

<body (optional)>
```

#### Types

- `feat`: New feature (e.g., "feat: Add Simon Says game")
- `fix`: Bug fix (e.g., "fix: Prevent crash on empty word list")
- `docs`: Documentation only (e.g., "docs: Update CONTRIBUTING.md")
- `style`: Code style changes (e.g., "style: Format with SwiftFormat")
- `refactor`: Code refactoring (e.g., "refactor: Extract shared UI components")
- `test`: Add or update tests (e.g., "test: Add Hangman win condition tests")
- `chore`: Maintenance tasks (e.g., "chore: Update Xcode project settings")
- `perf`: Performance improvements (e.g., "perf: Cache API responses")

#### Examples

```bash
# Good commits
git commit -m "feat: Add 2048 puzzle game"
git commit -m "fix: Timer leak in CountdownButton"
git commit -m "docs: Add architecture diagrams"
git commit -m "refactor: Extract GameHeaderView component"
git commit -m "test: Add Dictionary game API tests"

# Bad commits
git commit -m "updates"
git commit -m "fixed stuff"
git commit -m "wip"
```

### Commit Best Practices

1. **Atomic commits**: One logical change per commit
2. **Test before commit**: Ensure tests pass (`swift test`)
3. **Descriptive messages**: Explain what and why, not how
4. **Present tense**: "Add feature" not "Added feature"

---

## Pull Request Process

### Before Submitting

1. **Run tests**: `swift test` - All tests must pass
2. **Build successfully**: Cmd+B in Xcode
3. **Update documentation**: README, ARCHITECTURE.md if needed
4. **Add tests**: For new features
5. **Format code**: Follow style guide

### PR Title Format

Same as commit messages:

```
feat: Add Connect Four game
fix: Resolve memory leak in Memory game
docs: Update API documentation
```

### PR Description Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All existing tests pass
- [ ] Added new tests for changes
- [ ] Tested on iOS simulator
- [ ] Tested on physical device (if applicable)

## Checklist
- [ ] Code follows style guide
- [ ] Added/updated documentation
- [ ] No new warnings in Xcode
- [ ] Screenshots/GIFs (if UI changes)
```

### Review Process

1. **Automated checks**: GitHub Actions runs tests
2. **Code review**: Maintainer reviews code
3. **Feedback**: Address review comments
4. **Approval**: PR approved by maintainer
5. **Merge**: Squash and merge to main

---

## Additional Resources

- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- **Testing**: See [TESTING.md](TESTING.md) for testing guide
- **APIs**: See [API.md](API.md) for external API documentation
- **Swift Docs**: [Swift.org](https://swift.org/documentation/)
- **SwiftUI Docs**: [Apple Developer](https://developer.apple.com/documentation/swiftui)

---

## Getting Help

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Start a discussion for questions
- **Email**: Contact maintainer at [your-email]

---

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the code, not the person
- Follow community guidelines

---

**Thank you for contributing!** 🎉

Your improvements make this project better for everyone.
