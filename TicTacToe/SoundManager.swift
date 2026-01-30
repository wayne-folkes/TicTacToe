import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

/// Manager for sound effects throughout the app
@MainActor
class SoundManager {
    static let shared = SoundManager()
    
    /// Sound types available in the app
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
    
    /// Play a sound effect
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
    
    /// Setup audio session for sound playback
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
    
    /// Play haptic feedback along with sound (convenience method)
    func playWithHaptic(_ sound: SoundType, hapticStyle: HapticManager.FeedbackStyle = .light) {
        play(sound)
        HapticManager.shared.impact(style: hapticStyle)
    }
}
