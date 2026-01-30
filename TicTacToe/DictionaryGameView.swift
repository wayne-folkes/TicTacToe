import SwiftUI

struct DictionaryGameView: View {
    @StateObject private var gameState = DictionaryGameState()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with GameHeaderView
                GameHeaderView(
                    title: "Dictionary Game",
                    score: gameState.score,
                    scoreColor: .primary
                )
                
                // Difficulty Selector
                Picker("Difficulty", selection: Binding(
                    get: { gameState.difficulty },
                    set: { gameState.setDifficulty($0) }
                )) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                
                if gameState.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .dictionaryAccent))
                            .scaleEffect(1.5)
                        Text("Fetching a random word...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(minHeight: 300)
                    .frame(maxWidth: .infinity)
                } else if let word = gameState.currentWord {
                    VStack(spacing: 16) {
                        Text("Definition of:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(word.term)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        ForEach(gameState.options, id: \.self) { option in
                            Button(action: {
                                SoundManager.shared.play(.tap)
                                gameState.checkAnswer(option)
                            }) {
                                Text(option)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .background(buttonColor(for: option))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            }
                            .disabled(gameState.selectedOption != nil)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if gameState.selectedOption != nil {
                        CountdownButton(action: {
                            SoundManager.shared.play(.click)
                            withAnimation {
                                gameState.nextQuestion()
                            }
                        })
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.scale)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.cardBackground)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func buttonColor(for option: String) -> Color {
        if let selected = gameState.selectedOption {
            if option == gameState.currentWord?.definition {
                return Color.successColor
            } else if option == selected {
                return Color.errorColor
            }
            return Color.elevatedCardBackground.opacity(0.5)
        }
        return Color.elevatedCardBackground
    }
}

#Preview {
    DictionaryGameView()
}
