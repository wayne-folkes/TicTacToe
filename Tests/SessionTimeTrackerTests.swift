import XCTest
@testable import GamesApp

@MainActor
final class SessionTimeTrackerTests: XCTestCase {
    
    var tracker: SessionTimeTracker!
    
    override func setUp() async throws {
        tracker = SessionTimeTracker.shared
        // End any active session
        tracker.endSession()
    }
    
    override func tearDown() async throws {
        tracker.endSession()
    }
    
    // MARK: - Session Start/End Tests
    
    func testStartSessionSetsProperties() {
        tracker.startSession(for: "TicTacToe")
        
        XCTAssertEqual(tracker.currentGame, "TicTacToe")
        XCTAssertNotNil(tracker.sessionStartTime)
        XCTAssertTrue(tracker.isActive)
        XCTAssertEqual(tracker.elapsedTime, 0, accuracy: 0.1)
    }
    
    func testEndSessionClearsProperties() {
        tracker.startSession(for: "Memory")
        tracker.endSession()
        
        XCTAssertNil(tracker.currentGame)
        XCTAssertNil(tracker.sessionStartTime)
        XCTAssertFalse(tracker.isActive)
        XCTAssertEqual(tracker.elapsedTime, 0)
    }
    
    func testStartingNewSessionEndsExisting() {
        tracker.startSession(for: "TicTacToe")
        XCTAssertEqual(tracker.currentGame, "TicTacToe")
        
        tracker.startSession(for: "Memory")
        XCTAssertEqual(tracker.currentGame, "Memory")
        XCTAssertTrue(tracker.isActive)
    }
    
    // MARK: - Time Tracking Tests
    
    func testElapsedTimeIncreases() async {
        tracker.startSession(for: "Hangman")
        
        let initialTime = tracker.elapsedTime
        
        // Wait 0.5 seconds
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertGreaterThan(tracker.elapsedTime, initialTime)
        XCTAssertGreaterThanOrEqual(tracker.elapsedTime, 0.4)
    }
    
    func testPauseSessionStopsTimer() async {
        tracker.startSession(for: "Dictionary")
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        tracker.pauseSession()
        let pausedTime = tracker.elapsedTime
        
        XCTAssertFalse(tracker.isActive)
        
        // Wait more
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Time should not have increased significantly
        XCTAssertEqual(tracker.elapsedTime, pausedTime, accuracy: 0.1)
    }
    
    func testResumeSessionContinuesTiming() async {
        tracker.startSession(for: "Memory")
        
        // Wait, pause, wait, resume
        try? await Task.sleep(nanoseconds: 200_000_000)
        tracker.pauseSession()
        let pausedTime = tracker.elapsedTime
        try? await Task.sleep(nanoseconds: 200_000_000)
        tracker.resumeSession()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Should have accumulated time from before pause and after resume
        XCTAssertGreaterThan(tracker.elapsedTime, pausedTime)
    }
    
    // MARK: - Format Time Tests
    
    func testFormatTimeSeconds() {
        let formatted = SessionTimeTracker.formatTime(45)
        XCTAssertEqual(formatted, "0:45")
    }
    
    func testFormatTimeMinutes() {
        let formatted = SessionTimeTracker.formatTime(90)
        XCTAssertEqual(formatted, "1:30")
    }
    
    func testFormatTimeHours() {
        let formatted = SessionTimeTracker.formatTime(3665)
        XCTAssertEqual(formatted, "1:01:05")
    }
    
    func testFormattedElapsedTime() async {
        tracker.startSession(for: "TicTacToe")
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let formatted = tracker.formattedElapsedTime
        XCTAssertTrue(formatted.contains(":"))
    }
}
