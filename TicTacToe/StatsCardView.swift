import SwiftUI

/// Shared component for displaying game statistics
struct StatsCardView: View {
    let title: String
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
