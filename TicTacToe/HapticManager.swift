import SwiftUI
import UIKit

/// Manager for haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Generate a light impact haptic feedback
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Generate a notification haptic feedback
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Generate a selection haptic feedback
    func selection() {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
