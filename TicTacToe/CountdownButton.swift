import SwiftUI
import Combine

struct CountdownButton: View {
    let action: () -> Void
    let duration: TimeInterval = 10.0
    
    @State private var progress: CGFloat = 1.0
    @State private var isActive: Bool = false
    
    // Create a timer publisher
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Button(action: {
            isActive = false
            action()
        }) {
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                
                // Progress Bar
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.teal.opacity(0.3)) // Increased opacity for better visibility of bar against white
                        .frame(width: geo.size.width * progress)
                        .animation(.linear(duration: 0.1), value: progress)
                }
                .mask(RoundedRectangle(cornerRadius: 15)) // Ensure it stays within bounds
                
                // Text
                Text("Next Word")
                    .font(.headline)
                    .foregroundColor(.teal)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .frame(height: 50)
            .shadow(radius: 5)
        }
        .onAppear {
            progress = 1.0
            isActive = true
        }
        .onDisappear {
            isActive = false
        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            
            let step = 0.1
            let totalSteps = duration / step
            let progressStep = 1.0 / totalSteps
            
            if progress > 0 {
                progress -= CGFloat(progressStep)
            } else {
                isActive = false
                action()
            }
        }
    }
}

