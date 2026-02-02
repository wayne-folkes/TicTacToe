import XCTest
@testable import GamesApp

@MainActor
final class GameHistoryTests: XCTestCase {
    
    var history: GameHistory!
    
    override func setUp() async throws {
        history = GameHistory.shared
        // Clear history before each test
        history.clearHistory()
    }
    
    override func tearDown() async throws {
        history.clearHistory()
    }
    
    // MARK: - Add Result Tests
    
    func testAddResultIncreasesCount() {
        XCTAssertEqual(history.results.count, 0)
        
        history.addResult(game: "TicTacToe", won: true, score: 10, duration: 120)
        
        XCTAssertEqual(history.results.count, 1)
    }
    
    func testAddResultStoresCorrectData() {
        history.addResult(game: "Memory", won: false, score: 25, duration: 180)
        
        let result = history.results.first!
        XCTAssertEqual(result.game, "Memory")
        XCTAssertFalse(result.won)
        XCTAssertEqual(result.score, 25)
        XCTAssertEqual(result.duration, 180)
    }
    
    func testAddResultPrependsToList() {
        history.addResult(game: "TicTacToe", won: true, score: 5, duration: 60)
        history.addResult(game: "Hangman", won: false, score: 3, duration: 90)
        
        XCTAssertEqual(history.results[0].game, "Hangman")
        XCTAssertEqual(history.results[1].game, "TicTacToe")
    }
    
    func testAddResultTrimsToMaxSize() {
        // Add 501 results (exceeds max of 500)
        for i in 0..<501 {
            history.addResult(game: "TicTacToe", won: i % 2 == 0, score: i, duration: 60)
        }
        
        XCTAssertEqual(history.results.count, 500)
    }
    
    // MARK: - Filter Tests
    
    func testResultsForGame() {
        history.addResult(game: "TicTacToe", won: true, score: 0, duration: 60)
        history.addResult(game: "Memory", won: true, score: 50, duration: 120)
        history.addResult(game: "TicTacToe", won: false, score: 0, duration: 45)
        
        let ticTacToeResults = history.results(for: "TicTacToe")
        
        XCTAssertEqual(ticTacToeResults.count, 2)
        XCTAssertTrue(ticTacToeResults.allSatisfy { $0.game == "TicTacToe" })
    }
    
    // MARK: - Win Rate Tests
    
    func testWinRateCalculation() {
        // Add 10 games: 7 wins, 3 losses
        for i in 0..<10 {
            history.addResult(game: "Hangman", won: i < 7, score: 10, duration: 60)
        }
        
        let winRate = history.winRate(for: "Hangman", lastDays: 7)
        
        XCTAssertEqual(winRate, 70.0, accuracy: 0.1)
    }
    
    func testWinRateForAllGames() {
        history.addResult(game: "TicTacToe", won: true, score: 0, duration: 60)
        history.addResult(game: "Memory", won: true, score: 50, duration: 120)
        history.addResult(game: "TicTacToe", won: false, score: 0, duration: 45)
        history.addResult(game: "Hangman", won: true, score: 8, duration: 90)
        
        let winRate = history.winRate(for: nil, lastDays: 7)
        
        // 3 wins out of 4 games = 75%
        XCTAssertEqual(winRate, 75.0, accuracy: 0.1)
    }
    
    func testWinRateWithNoGames() {
        let winRate = history.winRate(for: "TicTacToe", lastDays: 7)
        
        XCTAssertEqual(winRate, 0.0)
    }
    
    // MARK: - Daily Win Rates Tests
    
    func testDailyWinRatesReturnsCorrectNumberOfDays() {
        let dailyStats = history.dailyWinRates(for: "TicTacToe", lastDays: 7)
        
        XCTAssertEqual(dailyStats.count, 7)
    }
    
    func testDailyWinRatesAggregatesCorrectly() {
        // Add 3 wins and 2 losses for today
        for i in 0..<5 {
            history.addResult(game: "Memory", won: i < 3, score: 10, duration: 60)
        }
        
        let dailyStats = history.dailyWinRates(for: "Memory", lastDays: 7)
        let today = Calendar.current.startOfDay(for: Date())
        let todayStats = dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        XCTAssertNotNil(todayStats)
        XCTAssertEqual(todayStats?.gamesPlayed, 5)
        XCTAssertEqual(todayStats?.wins, 3)
        if let todayStats = todayStats {
            XCTAssertEqual(todayStats.winRate, 60.0, accuracy: 0.1)
        }
    }
    
    // MARK: - Persistence Tests
    
    func testClearHistoryRemovesAllResults() {
        history.addResult(game: "TicTacToe", won: true, score: 0, duration: 60)
        history.addResult(game: "Memory", won: true, score: 50, duration: 120)
        
        XCTAssertEqual(history.results.count, 2)
        
        history.clearHistory()
        
        XCTAssertEqual(history.results.count, 0)
    }
}
