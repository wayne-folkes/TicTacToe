import Foundation
import Combine

/// Model representing a single game result with timestamp for historical tracking.
///
/// Used to store time-series data for win rate trends and performance analysis.
struct GameResult: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let game: String  // "TicTacToe", "Memory", "Dictionary", "Hangman"
    let won: Bool
    let score: Int
    let duration: TimeInterval  // Session duration in seconds
    
    init(game: String, won: Bool, score: Int, duration: TimeInterval) {
        self.id = UUID()
        self.timestamp = Date()
        self.game = game
        self.won = won
        self.score = score
        self.duration = duration
    }
}

/// Manages historical game results for trend analysis and charting.
///
/// Stores up to 500 recent game results in UserDefaults as JSON data.
/// Provides aggregation methods for daily/weekly win rates and performance metrics.
@MainActor
class GameHistory: ObservableObject {
    /// Shared singleton instance
    static let shared = GameHistory()
    
    private let userDefaults = UserDefaults.standard
    private let maxResults = 500
    private let historyKey = "gameHistoryResults"
    
    /// All stored game results, newest first
    @Published var results: [GameResult] = []
    
    private init() {
        loadFromUserDefaults()
    }
    
    /// Add a new game result to history.
    ///
    /// - Parameters:
    ///   - game: Game identifier
    ///   - won: Whether the game was won
    ///   - score: Final score
    ///   - duration: Session duration in seconds
    func addResult(game: String, won: Bool, score: Int, duration: TimeInterval) {
        let result = GameResult(game: game, won: won, score: score, duration: duration)
        results.insert(result, at: 0)
        
        // Trim to max size
        if results.count > maxResults {
            results = Array(results.prefix(maxResults))
        }
        
        saveToUserDefaults()
    }
    
    /// Get results for a specific game.
    func results(for game: String) -> [GameResult] {
        results.filter { $0.game == game }
    }
    
    /// Get win rate for a specific time period.
    ///
    /// - Parameters:
    ///   - game: Game identifier (nil for all games)
    ///   - days: Number of days to look back
    /// - Returns: Win rate as percentage (0-100)
    func winRate(for game: String? = nil, lastDays days: Int = 7) -> Double {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let recentResults = results.filter { result in
            result.timestamp >= cutoffDate &&
            (game == nil || result.game == game)
        }
        
        guard !recentResults.isEmpty else { return 0 }
        
        let wins = recentResults.filter { $0.won }.count
        return Double(wins) / Double(recentResults.count) * 100
    }
    
    /// Get daily aggregated win rates for charting.
    ///
    /// - Parameters:
    ///   - game: Game identifier (nil for all games)
    ///   - days: Number of days to include
    /// - Returns: Array of daily data points
    func dailyWinRates(for game: String? = nil, lastDays days: Int = 30) -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dailyStats: [Date: DailyStats] = [:]
        
        // Initialize all days with zero
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                dailyStats[date] = DailyStats(date: date, gamesPlayed: 0, wins: 0)
            }
        }
        
        // Aggregate results by day
        for result in results {
            let resultDay = calendar.startOfDay(for: result.timestamp)
            
            // Skip if outside our date range or wrong game
            guard dailyStats[resultDay] != nil,
                  game == nil || result.game == game else {
                continue
            }
            
            dailyStats[resultDay]?.gamesPlayed += 1
            if result.won {
                dailyStats[resultDay]?.wins += 1
            }
        }
        
        return dailyStats.values.sorted { $0.date < $1.date }
    }
    
    /// Get average score trend over time.
    func averageScores(for game: String, lastDays days: Int = 30) -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dailyScores: [Date: (totalScore: Int, count: Int)] = [:]
        
        for result in results.filter({ $0.game == game }) {
            let resultDay = calendar.startOfDay(for: result.timestamp)
            
            // Only include last N days
            if let daysDiff = calendar.dateComponents([.day], from: resultDay, to: today).day,
               daysDiff < days {
                let current = dailyScores[resultDay] ?? (0, 0)
                dailyScores[resultDay] = (current.totalScore + result.score, current.count + 1)
            }
        }
        
        return dailyScores.map { date, data in
            let avgScore = data.count > 0 ? data.totalScore / data.count : 0
            return DailyStats(date: date, gamesPlayed: data.count, wins: 0, averageScore: avgScore)
        }.sorted { $0.date < $1.date }
    }
    
    /// Clear all historical data.
    func clearHistory() {
        results = []
        saveToUserDefaults()
    }
    
    // MARK: - Private Methods
    
    private func loadFromUserDefaults() {
        guard let data = userDefaults.data(forKey: historyKey) else {
            results = []
            return
        }
        
        do {
            results = try JSONDecoder().decode([GameResult].self, from: data)
        } catch {
            print("Failed to decode game history: \(error)")
            results = []
        }
    }
    
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(results)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            print("Failed to encode game history: \(error)")
        }
    }
}

/// Aggregated statistics for a single day.
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    var gamesPlayed: Int
    var wins: Int
    var averageScore: Int = 0
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(wins) / Double(gamesPlayed) * 100
    }
}
