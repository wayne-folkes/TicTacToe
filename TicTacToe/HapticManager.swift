import SwiftUI
#if canImport(UIKit)
import UIKit

/// Centralized manager for haptic feedback throughout the app (iOS implementation).
///
/// This singleton class provides a simple interface for generating haptic feedback using
/// UIKit's feedback generators. Haptic feedback enhances the user experience by providing
/// tactile responses to interactions like button taps, game events, and state changes.
///
/// ## Features
/// - **Three Feedback Types**: Impact, notification, and selection haptics
/// - **User Control**: Respects user's haptic preference from GameStatistics
/// - **Thread Safety**: Marked `@MainActor` for safe SwiftUI integration
/// - **Platform-Aware**: iOS-only implementation with stub for other platforms
///
/// ## Usage
/// ```swift
/// // Light impact for button taps
/// HapticManager.shared.impact(style: .light)
///
/// // Notification feedback for game events
/// HapticManager.shared.notification(type: .success)
///
/// // Selection feedback for picker changes
/// HapticManager.shared.selection()
/// ```
///
/// - Note: Haptic feedback only works on physical devices, not in the simulator
/// - Important: Always check `GameStatistics.shared.hapticsEnabled` before generating feedback
@MainActor
class HapticManager {
    /// Shared singleton instance
    static let shared = HapticManager()
    
    private init() {}
    
    /// Generate an impact haptic feedback with the specified intensity.
    ///
    /// Use impact feedback for physical interactions like button taps, collisions,
    /// or object movements. Different styles provide varying intensity levels.
    ///
    /// - Parameter style: The intensity of the impact feedback (default: `.light`)
    ///   - `.light`: Subtle feedback for lightweight UI interactions
    ///   - `.medium`: Moderate feedback for standard interactions
    ///   - `.heavy`: Strong feedback for significant actions
    ///   - `.soft`: Gentle feedback for subtle transitions
    ///   - `.rigid`: Firm feedback for decisive actions
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Generate a notification haptic feedback for system events.
    ///
    /// Use notification feedback to communicate the result of a task or action,
    /// such as completing a level, winning a game, or encountering an error.
    ///
    /// - Parameter type: The type of notification feedback
    ///   - `.success`: Positive outcome (game won, correct answer)
    ///   - `.warning`: Cautionary outcome (low score, time running out)
    ///   - `.error`: Negative outcome (game lost, incorrect answer)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Generate a selection haptic feedback for picker or segmented control changes.
    ///
    /// Use selection feedback when the user changes a selection, such as scrolling
    /// through a picker, switching tabs, or changing settings.
    func selection() {
        guard GameStatistics.shared.hapticsEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

#else

/// Centralized manager for haptic feedback (stub for non-iOS platforms).
///
/// This is a no-op implementation for platforms that don't support UIKit haptic feedback,
/// such as macOS. It provides the same API as the iOS version for code compatibility.
///
/// - Note: All methods are no-ops on non-iOS platforms
@MainActor
class HapticManager {
    /// Shared singleton instance
    static let shared = HapticManager()
    
    /// Feedback style enum for API compatibility
    enum FeedbackStyle { case light, medium, heavy, soft, rigid }
    
    /// Feedback type enum for API compatibility
    enum FeedbackType { case success, warning, error }
    
    private init() {}
    
    /// No-op impact feedback for non-iOS platforms
    func impact(style: FeedbackStyle = .light) {
        // No-op on non-iOS platforms
    }
    
    /// No-op notification feedback for non-iOS platforms
    func notification(type: FeedbackType) {
        // No-op on non-iOS platforms
    }
    
    /// No-op selection feedback for non-iOS platforms
    func selection() {
        // No-op on non-iOS platforms
    }
}

#endif
