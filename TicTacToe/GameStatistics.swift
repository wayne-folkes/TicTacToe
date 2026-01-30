import Foundation

/// Manages persistent storage of game statistics and user preferences
@MainActor
class GameStatistics: ObservableObject {
    static let shared = GameStatistics()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        // Tic-Tac-Toe
        static let ticTacToeGamesPlayed = "ticTacToeGamesPlayed"
        static let ticTacToeXWins = "ticTacToeXWins"
        static let ticTacToeOWins = "ticTacToeOWins"
        static let ticTacToeDraws = "ticTacToeDraws"
        
        // Memory Game
        static let memoryGamesPlayed = "memoryGamesPlayed"
        static let memoryGamesWon = "memoryGamesWon"
        static let memoryHighScore = "memoryHighScore"
        static let memoryPreferredTheme = "memoryPreferredTheme"
        
        // Dictionary Game
        static let dictionaryGamesPlayed = "dictionaryGamesPlayed"
        static let dictionaryHighScore = "dictionaryHighScore"
        static let dictionaryPreferredDifficulty = "dictionaryPreferredDifficulty"
        
        // Hangman
        static let hangmanGamesPlayed = "hangmanGamesPlayed"
        static let hangmanGamesWon = "hangmanGamesWon"
        static let hangmanGamesLost = "hangmanGamesLost"
        static let hangmanHighScore = "hangmanHighScore"
        static let hangmanPreferredCategory = "hangmanPreferredCategory"
        
        // User Preferences
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
    }
    
    // MARK: - Tic-Tac-Toe Statistics
    @Published var ticTacToeGamesPlayed: Int {
        didSet { userDefaults.set(ticTacToeGamesPlayed, forKey: Keys.ticTacToeGamesPlayed) }
    }
    
    @Published var ticTacToeXWins: Int {
        didSet { userDefaults.set(ticTacToeXWins, forKey: Keys.ticTacToeXWins) }
    }
    
    @Published var ticTacToeOWins: Int {
        didSet { userDefaults.set(ticTacToeOWins, forKey: Keys.ticTacToeOWins) }
    }
    
    @Published var ticTacToeDraws: Int {
        didSet { userDefaults.set(ticTacToeDraws, forKey: Keys.ticTacToeDraws) }
    }
    
    // MARK: - Memory Game Statistics
    @Published var memoryGamesPlayed: Int {
        didSet { userDefaults.set(memoryGamesPlayed, forKey: Keys.memoryGamesPlayed) }
    }
    
    @Published var memoryGamesWon: Int {
        didSet { userDefaults.set(memoryGamesWon, forKey: Keys.memoryGamesWon) }
    }
    
    @Published var memoryHighScore: Int {
        didSet { userDefaults.set(memoryHighScore, forKey: Keys.memoryHighScore) }
    }
    
    @Published var memoryPreferredTheme: String {
        didSet { userDefaults.set(memoryPreferredTheme, forKey: Keys.memoryPreferredTheme) }
    }
    
    // MARK: - Dictionary Game Statistics
    @Published var dictionaryGamesPlayed: Int {
        didSet { userDefaults.set(dictionaryGamesPlayed, forKey: Keys.dictionaryGamesPlayed) }
    }
    
    @Published var dictionaryHighScore: Int {
        didSet { userDefaults.set(dictionaryHighScore, forKey: Keys.dictionaryHighScore) }
    }
    
    @Published var dictionaryPreferredDifficulty: String {
        didSet { userDefaults.set(dictionaryPreferredDifficulty, forKey: Keys.dictionaryPreferredDifficulty) }
    }
    
    // MARK: - Hangman Statistics
    @Published var hangmanGamesPlayed: Int {
        didSet { userDefaults.set(hangmanGamesPlayed, forKey: Keys.hangmanGamesPlayed) }
    }
    
    @Published var hangmanGamesWon: Int {
        didSet { userDefaults.set(hangmanGamesWon, forKey: Keys.hangmanGamesWon) }
    }
    
    @Published var hangmanGamesLost: Int {
        didSet { userDefaults.set(hangmanGamesLost, forKey: Keys.hangmanGamesLost) }
    }
    
    @Published var hangmanHighScore: Int {
        didSet { userDefaults.set(hangmanHighScore, forKey: Keys.hangmanHighScore) }
    }
    
    @Published var hangmanPreferredCategory: String {
        didSet { userDefaults.set(hangmanPreferredCategory, forKey: Keys.hangmanPreferredCategory) }
    }
    
    // MARK: - User Preferences
    @Published var soundEnabled: Bool {
        didSet { userDefaults.set(soundEnabled, forKey: Keys.soundEnabled) }
    }
    
    @Published var hapticsEnabled: Bool {
        didSet { userDefaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }
    
    // MARK: - Computed Properties
    var totalGamesPlayed: Int {
        ticTacToeGamesPlayed + memoryGamesPlayed + dictionaryGamesPlayed + hangmanGamesPlayed
    }
    
    var ticTacToeWinRate: Double {
        guard ticTacToeGamesPlayed > 0 else { return 0 }
        return Double(ticTacToeXWins + ticTacToeOWins) / Double(ticTacToeGamesPlayed) * 100
    }
    
    var memoryWinRate: Double {
        guard memoryGamesPlayed > 0 else { return 0 }
        return Double(memoryGamesWon) / Double(memoryGamesPlayed) * 100
    }
    
    var hangmanWinRate: Double {
        guard hangmanGamesPlayed > 0 else { return 0 }
        return Double(hangmanGamesWon) / Double(hangmanGamesPlayed) * 100
    }
    
    // MARK: - Initialization
    private init() {
        // Load Tic-Tac-Toe stats
        self.ticTacToeGamesPlayed = userDefaults.integer(forKey: Keys.ticTacToeGamesPlayed)
        self.ticTacToeXWins = userDefaults.integer(forKey: Keys.ticTacToeXWins)
        self.ticTacToeOWins = userDefaults.integer(forKey: Keys.ticTacToeOWins)
        self.ticTacToeDraws = userDefaults.integer(forKey: Keys.ticTacToeDraws)
        
        // Load Memory game stats
        self.memoryGamesPlayed = userDefaults.integer(forKey: Keys.memoryGamesPlayed)
        self.memoryGamesWon = userDefaults.integer(forKey: Keys.memoryGamesWon)
        self.memoryHighScore = userDefaults.integer(forKey: Keys.memoryHighScore)
        self.memoryPreferredTheme = userDefaults.string(forKey: Keys.memoryPreferredTheme) ?? "Animals"
        
        // Load Dictionary game stats
        self.dictionaryGamesPlayed = userDefaults.integer(forKey: Keys.dictionaryGamesPlayed)
        self.dictionaryHighScore = userDefaults.integer(forKey: Keys.dictionaryHighScore)
        self.dictionaryPreferredDifficulty = userDefaults.string(forKey: Keys.dictionaryPreferredDifficulty) ?? "Medium"
        
        // Load Hangman stats
        self.hangmanGamesPlayed = userDefaults.integer(forKey: Keys.hangmanGamesPlayed)
        self.hangmanGamesWon = userDefaults.integer(forKey: Keys.hangmanGamesWon)
        self.hangmanGamesLost = userDefaults.integer(forKey: Keys.hangmanGamesLost)
        self.hangmanHighScore = userDefaults.integer(forKey: Keys.hangmanHighScore)
        self.hangmanPreferredCategory = userDefaults.string(forKey: Keys.hangmanPreferredCategory) ?? "Animals"
        
        // Load user preferences
        self.soundEnabled = userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        self.hapticsEnabled = userDefaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
    }
    
    // MARK: - Public Methods
    
    /// Record a Tic-Tac-Toe game result
    func recordTicTacToeGame(winner: Player?, isDraw: Bool) {
        ticTacToeGamesPlayed += 1
        
        if isDraw {
            ticTacToeDraws += 1
        } else if let winner = winner {
            if winner == .x {
                ticTacToeXWins += 1
            } else {
                ticTacToeOWins += 1
            }
        }
    }
    
    /// Record a Memory game result
    func recordMemoryGame(score: Int, won: Bool) {
        memoryGamesPlayed += 1
        
        if won {
            memoryGamesWon += 1
        }
        
        if score > memoryHighScore {
            memoryHighScore = score
        }
    }
    
    /// Record a Dictionary game score
    func recordDictionaryGame(score: Int) {
        dictionaryGamesPlayed += 1
        
        if score > dictionaryHighScore {
            dictionaryHighScore = score
        }
    }
    
    /// Record a Hangman game result
    func recordHangmanGame(score: Int, won: Bool) {
        hangmanGamesPlayed += 1
        
        if won {
            hangmanGamesWon += 1
        } else {
            hangmanGamesLost += 1
        }
        
        if score > hangmanHighScore {
            hangmanHighScore = score
        }
    }
    
    /// Reset all statistics
    func resetAllStatistics() {
        // Reset Tic-Tac-Toe
        ticTacToeGamesPlayed = 0
        ticTacToeXWins = 0
        ticTacToeOWins = 0
        ticTacToeDraws = 0
        
        // Reset Memory
        memoryGamesPlayed = 0
        memoryGamesWon = 0
        memoryHighScore = 0
        
        // Reset Dictionary
        dictionaryGamesPlayed = 0
        dictionaryHighScore = 0
        
        // Reset Hangman
        hangmanGamesPlayed = 0
        hangmanGamesWon = 0
        hangmanGamesLost = 0
        hangmanHighScore = 0
    }
}
