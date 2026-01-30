import SwiftUI

struct DictionaryGameView: View {
    @StateObject private var gameState = DictionaryGameState()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Clean background following Apple HIG
            Color.cardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
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
                .padding(.horizontal)
                
                Spacer()
                
                if gameState.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .dictionaryAccent))
                            .scaleEffect(1.5)
                        Text("Fetching a random word...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let word = gameState.currentWord {
                    VStack(spacing: 10) {
                        Text("Definition of:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(word.term)
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.primary)
                    }
                    .padding()
                    
                    VStack(spacing: 15) {
                        ForEach(gameState.options, id: \.self) { option in
                            Button(action: {
                                SoundManager.shared.play(.tap)
                                gameState.checkAnswer(option)
                            }) {
                                Text(option)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonColor(for: option))
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                            }
                            .disabled(gameState.selectedOption != nil)
                        }
                    }
                    .padding()
                    
                    if gameState.selectedOption != nil {
                        CountdownButton(action: {
                            SoundManager.shared.play(.click)
                            withAnimation {
                                gameState.nextQuestion()
                            }
                        })
                        .padding(.horizontal)
                        .transition(.scale)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
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
