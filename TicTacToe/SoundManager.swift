import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

/// Centralized manager for sound effects throughout the app.
///
/// This singleton class manages audio playback using system sounds from AVFoundation.
/// It respects user preferences and provides platform-appropriate sound effects across
/// all games in the app.
///
/// ## Features
/// - **6 Sound Types**: tap, flip, success, win, lose, click
/// - **System Sounds**: Uses `AudioServicesPlaySystemSound` for instant playback
/// - **User Control**: Respects `GameStatistics.shared.soundEnabled` setting
/// - **Platform-Aware**: iOS implementation with graceful fallback
/// - **Combined Feedback**: Can play sound + haptic simultaneously
///
/// ## Usage
/// ```swift
/// // Play a simple sound
/// SoundManager.shared.play(.tap)
///
/// // Play sound with haptic feedback
/// SoundManager.shared.playWithHaptic(.success, hapticStyle: .medium)
///
/// // Different sounds for different game events
/// SoundManager.shared.play(.win)     // Victory!
/// SoundManager.shared.play(.lose)    // Game over
/// SoundManager.shared.play(.flip)    // Card flip animation
/// ```
///
/// ## Future Enhancement
/// The current implementation uses system sounds (AudioServicesPlaySystemSound).
/// This can be replaced with custom audio files using AVAudioPlayer for
/// more branded/unique sound effects. See CONTRIBUTING.md for details.
///
/// - Note: Sound playback is silent in Xcode simulator by default
/// - Important: Must be accessed from the main actor/thread
@MainActor
class SoundManager {
    /// Shared singleton instance
    static let shared = SoundManager()
    
    /// Available sound effect types for different game interactions.
    ///
    /// Each sound type corresponds to a specific user interaction or game event:
    /// - `tap`: Short click for button presses and cell selections
    /// - `flip`: Swoosh sound for card flipping animations
    /// - `success`: Positive chime for correct answers or matches
    /// - `win`: Victory fanfare for completing a game successfully
    /// - `lose`: Failure tone for losing a game or incorrect answers
    /// - `click`: Alternative click for letter selections in Hangman
    enum SoundType {
        case tap        // Button/cell tap
        case flip       // Card flip in Memory
        case success    // Correct answer/match
        case win        // Game won
        case lose       // Game lost
        case click      // Letter selection in Hangman
    }
    
    private init() {
        setupAudioSession()
    }
    
    /// Play a sound effect if sound is enabled.
    ///
    /// This method checks the user's sound preference before playing audio.
    /// Currently uses system sound IDs for instant playback with zero latency.
    ///
    /// - Parameter sound: The type of sound effect to play
    ///
    /// - Note: System sound IDs are iOS-specific and may vary between iOS versions
    func play(_ sound: SoundType) {
        guard GameStatistics.shared.soundEnabled else { return }
        
        #if canImport(UIKit)
        // Use system sound IDs for now (can be replaced with custom sounds later)
        let soundID: SystemSoundID = {
            switch sound {
            case .tap:
                return 1104 // Tock sound
            case .flip:
                return 1105 // Swoosh
            case .success:
                return 1054 // Short success beep
            case .win:
                return 1016 // Long success tone
            case .lose:
                return 1053 // Short error tone
            case .click:
                return 1103 // Click sound
            }
        }()
        
        AudioServicesPlaySystemSound(soundID)
        #endif
    }
    
    /// Setup the audio session for ambient sound playback.
    ///
    /// Configures AVAudioSession to play sounds alongside other audio (e.g., music apps).
    /// The `.ambient` category allows sounds to mix with other audio sources and respects
    /// the device's silent mode.
    ///
    /// - Note: Called automatically during initialization
    private func setupAudioSession() {
        #if canImport(UIKit)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    #if canImport(UIKit)
    /// Play a sound effect combined with haptic feedback (iOS only).
    ///
    /// This convenience method plays audio and triggers haptic feedback simultaneously
    /// for a more immersive user experience. Both sound and haptics respect their
    /// respective user preference settings.
    ///
    /// - Parameters:
    ///   - sound: The type of sound effect to play
    ///   - hapticStyle: The intensity of haptic feedback (default: `.light`)
    ///
    /// Example:
    /// ```swift
    /// // Light tap for button press
    /// SoundManager.shared.playWithHaptic(.tap, hapticStyle: .light)
    ///
    /// // Strong feedback for game win
    /// SoundManager.shared.playWithHaptic(.win, hapticStyle: .heavy)
    /// ```
    func playWithHaptic(_ sound: SoundType, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        play(sound)
        HapticManager.shared.impact(style: hapticStyle)
    }
    #else
    /// Play a sound effect combined with haptic feedback (non-UIKit platforms).
    ///
    /// Stub implementation for platform compatibility. Sound will play but haptic
    /// feedback is a no-op on non-iOS platforms.
    func playWithHaptic(_ sound: SoundType, hapticStyle: HapticManager.FeedbackStyle = .light) {
        play(sound)
        HapticManager.shared.impact(style: hapticStyle)
    }
    #endif
}
