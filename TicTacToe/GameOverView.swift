import SwiftUI

/// Shared game over view component for all games
/// Displays win/lose message and action buttons
struct GameOverView: View {
    let message: String
    let isSuccess: Bool
    let onPlayAgain: () -> Void
    let secondaryButtonTitle: String?
    let onSecondaryAction: (() -> Void)?
    
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
