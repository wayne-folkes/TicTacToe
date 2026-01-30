import SwiftUI
#if canImport(UIKit)
import UIKit

/// Manager for haptic feedback throughout the app
@MainActor
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

#else

/// Manager for haptic feedback throughout the app (stub for non-iOS platforms)
@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    enum FeedbackStyle { case light, medium, heavy, soft, rigid }
    enum FeedbackType { case success, warning, error }
    
    private init() {}
    
    func impact(style: FeedbackStyle = .light) {
        // No-op on non-iOS platforms
    }
    
    func notification(type: FeedbackType) {
        // No-op on non-iOS platforms
    }
    
    func selection() {
        // No-op on non-iOS platforms
    }
}

#endif
