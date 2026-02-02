import Foundation
import Combine

/// Tracks active game session duration with automatic pause/resume on app lifecycle events.
///
/// This class provides precise session timing for individual games, handling app backgrounding
/// and foregrounding automatically. Time is accumulated and reported to `GameStatistics` when
/// a session ends.
///
/// ## Usage
/// ```swift
/// let tracker = SessionTimeTracker.shared
/// tracker.startSession(for: "TicTacToe")
/// // ... user plays game ...
/// tracker.endSession(for: "TicTacToe")  // Time saved to GameStatistics
/// ```
///
/// ## Lifecycle Handling
/// - Automatically pauses when app enters background
/// - Resumes when app returns to foreground
/// - Saves accumulated time on session end
///
/// - Important: Must be accessed from the main actor/thread
@MainActor
class SessionTimeTracker: ObservableObject {
    /// Shared singleton instance
    static let shared = SessionTimeTracker()
    
    /// Currently active game identifier (e.g., "TicTacToe", "Memory")
    @Published private(set) var currentGame: String?
    
    /// Start time of current session
    @Published private(set) var sessionStartTime: Date?
    
    /// Accumulated elapsed time for current session (in seconds)
    @Published private(set) var elapsedTime: TimeInterval = 0
    
    /// Whether session is currently active and timing
    @Published private(set) var isActive: Bool = false
    
    /// Timer for real-time updates
    private var timer: Timer?
    
    /// Time when app went to background (for pause calculation)
    private var backgroundTime: Date?
    
    /// Accumulated time before current timer started (for pause/resume)
    private var accumulatedTime: TimeInterval = 0
    
    private init() {}
    
    /// Start tracking time for a game session.
    ///
    /// - Parameter game: Game identifier (e.g., "TicTacToe", "Memory", "Dictionary", "Hangman")
    ///
    /// - Note: If a session is already active, it will be ended automatically
    func startSession(for game: String) {
        // End any existing session first
        if currentGame != nil {
            endSession()
        }
        
        currentGame = game
        sessionStartTime = Date()
        accumulatedTime = 0
        elapsedTime = 0
        isActive = true
        
        startTimer()
    }
    
    /// End the current session and record time to GameStatistics.
    ///
    /// Time is saved to `GameStatistics` for the current game and the session is reset.
    func endSession() {
        guard let game = currentGame else { return }
        
        stopTimer()
        
        // Calculate final duration
        let finalDuration = accumulatedTime + currentTimerDuration()
        
        // Record to GameStatistics
        if finalDuration > 0 {
            GameStatistics.shared.recordSessionTime(finalDuration, for: game)
        }
        
        // Reset state
        currentGame = nil
        sessionStartTime = nil
        elapsedTime = 0
        accumulatedTime = 0
        isActive = false
    }
    
    /// Pause the current session (called when app backgrounds).
    func pauseSession() {
        guard isActive else { return }
        
        stopTimer()
        
        // Save accumulated time up to this point
        accumulatedTime += currentTimerDuration()
        elapsedTime = accumulatedTime
        
        backgroundTime = Date()
        isActive = false
    }
    
    /// Resume the current session (called when app foregrounds).
    func resumeSession() {
        guard currentGame != nil, !isActive else { return }
        
        // Reset session start time to now (we already saved accumulated time)
        sessionStartTime = Date()
        backgroundTime = nil
        isActive = true
        
        startTimer()
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard isActive else { return }
        elapsedTime = accumulatedTime + currentTimerDuration()
    }
    
    private func currentTimerDuration() -> TimeInterval {
        guard let startTime = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Get formatted elapsed time string (e.g., "1:23" for 1 minute 23 seconds)
    var formattedElapsedTime: String {
        SessionTimeTracker.formatTime(elapsedTime)
    }
    
    /// Format time interval into readable string
    static func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
