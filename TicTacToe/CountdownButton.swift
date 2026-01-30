import SwiftUI

struct CountdownButton: View {
    let action: () -> Void
    let duration: TimeInterval = 10.0
    
    @State private var progress: CGFloat = 1.0
    @State private var timer: Timer? = nil
    
    var body: some View {
        Button(action: {
            cancelTimer()
            action()
        }) {
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)

                // Progress Bar (underlay)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.teal.opacity(0.25))
                        .frame(width: geo.size.width * progress)
                        .animation(.linear(duration: 0.1), value: progress)
                }
                .mask(RoundedRectangle(cornerRadius: 15))
                .zIndex(0)
                .allowsHitTesting(false)

                // Text (on top, static)
                Text("Next Word")
                    .font(.headline)
                    .foregroundColor(Color(white: 0.1))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.95), in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .overlay(Capsule().stroke(Color.teal.opacity(0.2), lineWidth: 1))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .zIndex(1)
                    .transaction { $0.animation = nil }
            }
            .frame(height: 50)
            .shadow(radius: 5)
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            cancelTimer()
        }
    }
    
    private func startCountdown() {
        progress = 1.0
        let step = 0.1
        let totalSteps = duration / step
        let progressStep = 1.0 / totalSteps
        
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { [self] timer in
            DispatchQueue.main.async {
                if progress > 0 {
                    progress -= CGFloat(progressStep)
                } else {
                    if timer.isValid {
                        cancelTimer()
                        action()
                    }
                }
            }
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}

