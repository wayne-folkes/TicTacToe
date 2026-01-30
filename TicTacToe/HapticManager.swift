import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Manager for haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Generate a light impact haptic feedback
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        #if canImport(UIKit)
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
    
    /// Generate a notification haptic feedback
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        #if canImport(UIKit)
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #endif
    }
    
    /// Generate a selection haptic feedback
    func selection() {
        #if canImport(UIKit)
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}
