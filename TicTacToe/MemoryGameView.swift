import SwiftUI

struct MemoryGameView: View {
    @StateObject private var gameState = MemoryGameState()
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Memory Game")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Score: \(gameState.score)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
                // Theme Selector
                Picker("Theme", selection: Binding(
                    get: { gameState.currentTheme },
                    set: { gameState.toggleTheme($0) }
                )) {
                    ForEach(MemoryGameState.MemoryTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(gameState.cards) { card in
                            CardView(card: card)
                                .aspectRatio(2/3, contentMode: .fit)
                                .onTapGesture {
                                    HapticManager.shared.impact(style: .light)
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        gameState.choose(card)
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                if gameState.isGameOver {
                    Button(action: {
                        showConfetti = false
                        withAnimation {
                            gameState.startNewGame()
                        }
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
                    .transition(.scale)
                }
            }
            .padding(.top, 50)
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: gameState.isGameOver) { _, newValue in
            if newValue {
                HapticManager.shared.notification(type: .success)
                withAnimation(.easeIn(duration: 0.3)) {
                    showConfetti = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showConfetti = false
                    }
                }
            }
        }
    }
}

struct CardView: View {
    let card: MemoryCard
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if card.isFaceUp || card.isMatched {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.purple, lineWidth: 3)
                        
                    Text(card.content)
                        .font(.system(size: geometry.size.width * 0.7))
                        .opacity(card.isMatched ? 0.5 : 1)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(radius: 2)
                }
            }
            .rotation3DEffect(Angle.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
    }
}

#Preview {
    MemoryGameView()
}
