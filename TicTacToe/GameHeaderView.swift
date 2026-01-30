import SwiftUI

/// Shared header component for all games
/// Displays game title, score, and optional status message
struct GameHeaderView: View {
    let title: String
    let score: Int
    let statusText: String?
    let scoreColor: Color
    
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
