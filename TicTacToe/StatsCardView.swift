import SwiftUI

/// Reusable statistics card component for displaying game metrics.
///
/// This component provides a consistent way to display game statistics in the settings
/// screen or anywhere statistics need to be shown. It uses a card-style design with
/// label-value pairs.
///
/// ## Usage
/// ```swift
/// StatsCardView(
///     title: "Tic Tac Toe",
///     items: [
///         ("Games Played", "42"),
///         ("Win Rate", "67.5%"),
///         ("Best Streak", "7")
///     ]
/// )
/// ```
///
/// - Note: The card background color adapts to light/dark mode via `Color.cardBackground`
struct StatsCardView: View {
    /// Title displayed at the top of the card (e.g., "Tic Tac Toe")
    let title: String
    
    /// Array of label-value pairs to display (e.g., [("Wins", "10"), ("Losses", "5")])
    let items: [(label: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(items, id: \.label) { item in
                HStack {
                    Text(item.label)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.value)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 20) {
        StatsCardView(
            title: "Tic Tac Toe",
            items: [
                ("Wins", "10"),
                ("Losses", "5"),
                ("Draws", "2")
            ]
        )
        StatsCardView(
            title: "Memory Game",
            items: [
                ("Games Played", "15"),
                ("Best Score", "100"),
                ("Average Score", "75")
            ]
        )
    }
    .padding()
}
