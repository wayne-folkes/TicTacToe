import SwiftUI

/// Game mode options for Tic-Tac-Toe.
enum GameMode: String, CaseIterable, Identifiable, Codable {
    case twoPlayer = "Two Player"
    case vsAI = "vs AI"
    
    var id: String { rawValue }
}

/// Difficulty levels for AI opponent.
enum AIDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .easy: return "Random moves"
        case .medium: return "Smart player"
        case .hard: return "Unbeatable"
        }
    }
}

/// AI opponent for Tic-Tac-Toe with configurable difficulty.
///
/// This class implements three difficulty levels:
/// - **Easy**: Random move selection
/// - **Medium**: Smart heuristic (win → block → center → corner → any)
/// - **Hard**: Minimax algorithm with depth scoring (unbeatable)
///
/// ## Algorithm Details
///
/// ### Easy AI
/// Randomly selects from available empty cells.
///
/// ### Medium AI
/// 1. Check if AI can win → take winning move
/// 2. Check if opponent can win → block
/// 3. Take center if available
/// 4. Take corner if available
/// 5. Take any remaining cell
///
/// ### Hard AI (Minimax)
/// Uses minimax algorithm with depth-based scoring:
/// - Evaluates all possible game trees
/// - Maximizes AI's score, minimizes opponent's
/// - Depth scoring ensures faster wins preferred
/// - Guarantees optimal play (never loses)
///
/// ## Usage
/// ```swift
/// let ai = AIPlayer(difficulty: .hard)
/// let board: [Player?] = [.x, nil, .o, ...]
/// let move = ai.chooseMove(board: board)
/// ```
@MainActor
class AIPlayer {
    let difficulty: AIDifficulty
    
    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
    }
    
    /// Choose the best move for the AI based on current difficulty.
    ///
    /// - Parameter board: Current 9-element board state
    /// - Returns: Index (0-8) of chosen move
    func chooseMove(board: [Player?]) -> Int {
        switch difficulty {
        case .easy:
            return easyMove(board: board)
        case .medium:
            return mediumMove(board: board)
        case .hard:
            return hardMove(board: board)
        }
    }
    
    // MARK: - Easy AI (Random)
    
    /// Select a random empty cell.
    private func easyMove(board: [Player?]) -> Int {
        let available = board.enumerated()
            .filter { $0.element == nil }
            .map { $0.offset }
        return available.randomElement() ?? 0
    }
    
    // MARK: - Medium AI (Heuristic)
    
    /// Use strategic heuristic: win → block → center → corner → any.
    private func mediumMove(board: [Player?]) -> Int {
        // 1. Try to win
        if let winMove = findWinningMove(board: board, player: .o) {
            return winMove
        }
        
        // 2. Block opponent's win
        if let blockMove = findWinningMove(board: board, player: .x) {
            return blockMove
        }
        
        // 3. Take center if available
        if board[4] == nil {
            return 4
        }
        
        // 4. Take corner
        let corners = [0, 2, 6, 8].filter { board[$0] == nil }
        if let corner = corners.randomElement() {
            return corner
        }
        
        // 5. Take any available
        return easyMove(board: board)
    }
    
    // MARK: - Hard AI (Minimax)
    
    /// Use minimax algorithm for optimal play.
    private func hardMove(board: [Player?]) -> Int {
        var bestScore = Int.min
        var bestMove = 0
        
        for i in 0..<9 {
            if board[i] == nil {
                var newBoard = board
                newBoard[i] = .o
                let score = minimax(board: newBoard, depth: 0, isMaximizing: false)
                if score > bestScore {
                    bestScore = score
                    bestMove = i
                }
            }
        }
        
        return bestMove
    }
    
    /// Minimax algorithm with alpha-beta pruning concept.
    ///
    /// - Parameters:
    ///   - board: Current board state to evaluate
    ///   - depth: Current depth in game tree (for scoring)
    ///   - isMaximizing: Whether current level maximizes (AI) or minimizes (opponent)
    /// - Returns: Score for this board state (positive = AI advantage)
    private func minimax(board: [Player?], depth: Int, isMaximizing: Bool) -> Int {
        // Check terminal states
        if let winner = checkWinner(board: board) {
            return winner == .o ? (10 - depth) : (depth - 10)
        }
        
        if !board.contains(nil) {
            return 0 // Draw
        }
        
        if isMaximizing {
            var maxScore = Int.min
            for i in 0..<9 {
                if board[i] == nil {
                    var newBoard = board
                    newBoard[i] = .o
                    let score = minimax(board: newBoard, depth: depth + 1, isMaximizing: false)
                    maxScore = max(score, maxScore)
                }
            }
            return maxScore
        } else {
            var minScore = Int.max
            for i in 0..<9 {
                if board[i] == nil {
                    var newBoard = board
                    newBoard[i] = .x
                    let score = minimax(board: newBoard, depth: depth + 1, isMaximizing: true)
                    minScore = min(score, minScore)
                }
            }
            return minScore
        }
    }
    
    // MARK: - Helper Methods
    
    /// Find a winning move for the specified player, if one exists.
    ///
    /// - Parameters:
    ///   - board: Current board state
    ///   - player: Player to find winning move for
    /// - Returns: Index of winning move, or nil if none exists
    private func findWinningMove(board: [Player?], player: Player) -> Int? {
        for i in 0..<9 {
            if board[i] == nil {
                var testBoard = board
                testBoard[i] = player
                if checkWinner(board: testBoard) == player {
                    return i
                }
            }
        }
        return nil
    }
    
    /// Check if there's a winner on the given board.
    ///
    /// - Parameter board: Board state to check
    /// - Returns: Winning player, or nil if no winner
    private func checkWinner(board: [Player?]) -> Player? {
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]              // Diagonals
        ]
        
        for pattern in winPatterns {
            let cells = pattern.map { board[$0] }
            if cells.allSatisfy({ $0 == .x }) {
                return .x
            } else if cells.allSatisfy({ $0 == .o }) {
                return .o
            }
        }
        
        return nil
    }
}
