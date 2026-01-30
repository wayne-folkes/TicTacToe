import SwiftUI

/// Reusable header component for displaying game titles, scores, and status.
///
/// This shared component provides a consistent header design across all four games
/// in the app. It displays the game name, current score, and an optional status message.
///
/// ## Usage
/// ```swift
/// GameHeaderView(
///     title: "Memory Game",
///     score: 150,
///     statusText: "12 pairs remaining",
///     scoreColor: .green
/// )
/// ```
///
/// - Note: The header includes top padding (60pt) to avoid status bar overlap
struct GameHeaderView: View {
    /// The game name to display (e.g., "Tic Tac Toe", "Memory Game")
    let title: String
    
    /// Current score or points
    let score: Int
    
    /// Optional status message (e.g., "X's Turn", "12 pairs left")
    let statusText: String?
    
    /// Color for the score text (default: primary color)
    let scoreColor: Color
    
    /// Creates a game header with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The name of the game
    ///   - score: The current score
    ///   - statusText: Optional status message to display below the score
    ///   - scoreColor: Color for the score text (default: `.primary`)
    init(
        title: String,
        score: Int,
        statusText: String? = nil,
        scoreColor: Color = .primary
    ) {
        self.title = title
        self.score = score
        self.statusText = statusText
        self.scoreColor = scoreColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(score)")
                .font(.title2)
                .foregroundColor(scoreColor)
            
            if let status = statusText {
                Text(status)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 60)
    }
}

#Preview {
    VStack(spacing: 40) {
        GameHeaderView(title: "Tic Tac Toe", score: 5, statusText: "X's Turn")
        GameHeaderView(title: "Memory Game", score: 100, scoreColor: .green)
        GameHeaderView(title: "Hangman", score: 0)
    }
}
