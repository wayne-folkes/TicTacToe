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
                
                if let word = gameState.currentWord {
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
                            AnswerOptionButton(
                                option: option,
                                backgroundColor: buttonColor(for: option),
                                isDisabled: gameState.selectedOption != nil,
                                onTap: {
                                    SoundManager.shared.play(.tap)
                                    gameState.checkAnswer(option)
                                }
                            )
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
        #if os(macOS)
        .onKeyPress { press in
            handleKeyPress(press)
        }
        #endif
    }
    
    #if os(macOS)
    /// Handles keyboard input on macOS for answer selection
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Number keys 1-4 to select answers
        guard let number = Int(press.characters),
              (1...4).contains(number) else {
            return .ignored
        }
        
        // Ignore if no options available or already answered
        guard gameState.options.count >= number,
              gameState.selectedOption == nil else {
            return .ignored
        }
        
        // Select the option at index (number - 1)
        let option = gameState.options[number - 1]
        SoundManager.shared.play(.click)
        gameState.checkAnswer(option)
        
        return .handled
    }
    #endif
    
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

// Separate answer button view to support hover state
struct AnswerOptionButton: View {
    let option: String
    let backgroundColor: Color
    let isDisabled: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            Text(option)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(16)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .background(backgroundColor)
                .cornerRadius(12)
                .shadow(color: .black.opacity(isHovered && !isDisabled ? 0.1 : 0.05), radius: isHovered && !isDisabled ? 4 : 2, y: 1)
                .scaleEffect(isHovered && !isDisabled ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .disabled(isDisabled)
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
        #endif
    }
}

#Preview {
    DictionaryGameView()
}
