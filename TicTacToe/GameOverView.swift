import SwiftUI

/// Reusable game over screen component for win/lose scenarios.
///
/// This shared component displays the game outcome with consistent styling across all games.
/// It shows a message (win/lose), provides a "Play Again" button, and supports an optional
/// secondary action button for additional functionality.
///
/// ## Features
/// - Automatic color coding (green for success, red for failure)
/// - Sound effects on button press
/// - Scale transition animation
/// - Optional secondary button (e.g., "Change Category", "New Game")
///
/// ## Usage
/// ```swift
/// GameOverView(
///     message: "🎉 You Won!",
///     isSuccess: true,
///     onPlayAgain: { startNewGame() },
///     secondaryButtonTitle: "Change Difficulty",
///     onSecondaryAction: { showSettings() }
/// )
/// ```
struct GameOverView: View {
    /// The message to display (e.g., "🎉 You Won!", "😢 Game Over")
    let message: String
    
    /// Whether this is a success (true) or failure (false) outcome
    let isSuccess: Bool
    
    /// Closure called when "Play Again" button is tapped
    let onPlayAgain: () -> Void
    
    /// Optional title for secondary button (e.g., "Change Category")
    let secondaryButtonTitle: String?
    
    /// Optional action for secondary button
    let onSecondaryAction: (() -> Void)?
    
    /// Creates a game over view with the specified parameters.
    ///
    /// - Parameters:
    ///   - message: The outcome message to display
    ///   - isSuccess: Whether to use success (green) or failure (red) styling
    ///   - onPlayAgain: Action to perform when "Play Again" is tapped
    ///   - secondaryButtonTitle: Optional title for a second button
    ///   - onSecondaryAction: Optional action for the second button
    init(
        message: String,
        isSuccess: Bool,
        onPlayAgain: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.isSuccess = isSuccess
        self.onPlayAgain = onPlayAgain
        self.secondaryButtonTitle = secondaryButtonTitle
        self.onSecondaryAction = onSecondaryAction
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(message)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isSuccess ? .green : .red)
                .multilineTextAlignment(.center)
            
            Button(action: {
                SoundManager.shared.play(.click)
                onPlayAgain()
            }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            if let secondaryTitle = secondaryButtonTitle,
               let secondaryAction = onSecondaryAction {
                Button(action: {
                    SoundManager.shared.play(.click)
                    secondaryAction()
                }) {
                    Text(secondaryTitle)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .transition(.scale)
    }
}

#Preview {
    VStack(spacing: 50) {
        GameOverView(message: "🎉 You Won!", isSuccess: true, onPlayAgain: {})
        GameOverView(message: "😢 Game Over", isSuccess: false, onPlayAgain: {})
        GameOverView(
            message: "It's a Draw!",
            isSuccess: false,
            onPlayAgain: {},
            secondaryButtonTitle: "Reset Stats",
            onSecondaryAction: {}
        )
    }
}
