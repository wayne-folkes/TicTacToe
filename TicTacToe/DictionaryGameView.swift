import SwiftUI

struct DictionaryGameView: View {
    @StateObject private var gameState = DictionaryGameState()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Text("Dictionary Game")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Score: \(gameState.score)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
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
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Fetching a random word...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let word = gameState.currentWord {
                    VStack(spacing: 10) {
                        Text("Definition of:")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(word.term)
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()
                    
                    VStack(spacing: 15) {
                        ForEach(gameState.options, id: \.self) { option in
                            Button(action: {
                                let isCorrect = option == gameState.currentWord?.definition
                                if isCorrect {
                                    HapticManager.shared.notification(type: .success)
                                } else {
                                    HapticManager.shared.notification(type: .error)
                                }
                                gameState.checkAnswer(option)
                            }) {
                                Text(option)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
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
                return Color.green.opacity(0.9)
            } else if option == selected {
                return Color.red.opacity(0.9)
            }
            return colorScheme == .dark ? Color(white: 0.3).opacity(0.5) : Color.white.opacity(0.5)
        }
        return colorScheme == .dark ? Color(white: 0.2) : Color.white.opacity(0.9)
    }
}

#Preview {
    DictionaryGameView()
}
