import SwiftUI
import Combine

/// Represents a player in the Tic-Tac-Toe game.
///
/// - Note: Raw values used for UI display (e.g., showing "X" or "O" in cells)
enum Player: String {
    case x = "X"
    case o = "O"
}

/// Game logic and state management for Tic-Tac-Toe.
///
/// This class implements the classic Tic-Tac-Toe game logic for two players on a 3x3 grid.
/// It handles move validation, turn switching, win detection (rows, columns, diagonals),
/// draw detection, and statistics tracking.
///
/// ## Features
/// - **Turn-Based**: Alternates between X and O players
/// - **Win Detection**: Checks all 8 winning patterns (3 rows, 3 columns, 2 diagonals)
/// - **Draw Detection**: Recognizes when all cells are filled with no winner
/// - **Move Validation**: Prevents invalid moves (occupied cells, game over)
/// - **Statistics**: Auto-records game results to GameStatistics
///
/// ## Usage
/// ```swift
/// @StateObject private var gameState = TicTacToeGameState()
///
/// // Make a move
/// gameState.makeMove(at: 4) // Center cell
///
/// // Check game state
/// if let winner = gameState.winner {
///     print("\(winner.rawValue) wins!")
/// }
///
/// // Start new game
/// gameState.resetGame()
/// ```
///
/// - Important: Must be accessed from the main actor/thread
@MainActor
class TicTacToeGameState: ObservableObject {
    /// 9-element array representing the 3x3 game board (nil = empty cell)
    /// - Note: Index layout: [0,1,2], [3,4,5], [6,7,8]
    @Published var board: [Player?]
    
    /// The player whose turn it is (X always goes first)
    @Published var currentPlayer: Player
    
    /// The winning player (nil if game is still in progress or ended in draw)
    @Published var winner: Player?
    
    /// Whether the game ended in a draw (all cells filled, no winner)
    @Published var isDraw: Bool
    
    /// Initialize a new game with an empty board and X as the starting player.
    init() {
        self.board = Array(repeating: nil, count: 9)
        self.currentPlayer = .x
        self.winner = nil
        self.isDraw = false
    }
    
    /// Attempt to place the current player's mark at the specified board position.
    ///
    /// This method validates the move, updates the board, checks for win/draw conditions,
    /// and switches to the next player if the game continues. If the game ends (win or draw),
    /// statistics are automatically recorded.
    ///
    /// - Parameter index: The board position (0-8) where the current player wants to move
    ///
    /// - Note: Invalid moves are silently ignored (occupied cell, game over, out of bounds)
    func makeMove(at index: Int) {
        guard board[index] == nil, winner == nil, !isDraw else { return }
        
        board[index] = currentPlayer
        
        if checkWin() {
            winner = currentPlayer
            GameStatistics.shared.recordTicTacToeGame(winner: currentPlayer, isDraw: false)
        } else if checkDraw() {
            isDraw = true
            GameStatistics.shared.recordTicTacToeGame(winner: nil, isDraw: true)
        } else {
            currentPlayer = currentPlayer == .x ? .o : .x
        }
    }
    
    /// Reset the game to initial state for a new round.
    ///
    /// Clears the board, resets to X's turn, and clears win/draw flags.
    /// Does not affect statistics.
    func resetGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .x
        winner = nil
        isDraw = false
    }
    
    /// Check if the current player has won the game.
    ///
    /// Evaluates all 8 winning patterns:
    /// - 3 horizontal rows: [0,1,2], [3,4,5], [6,7,8]
    /// - 3 vertical columns: [0,3,6], [1,4,7], [2,5,8]
    /// - 2 diagonals: [0,4,8], [2,4,6]
    ///
    /// - Returns: `true` if three matching marks form a line, `false` otherwise
    private func checkWin() -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]             // Diagonals
        ]
        
        for pattern in winPatterns {
            let p1 = board[pattern[0]]
            let p2 = board[pattern[1]]
            let p3 = board[pattern[2]]
            
            if let p1 = p1, p1 == p2, p1 == p3 {
                return true
            }
        }
        return false
    }
    
    /// Check if the game has ended in a draw.
    ///
    /// - Returns: `true` if all 9 cells are filled and there's no winner
    private func checkDraw() -> Bool {
        return board.compactMap { $0 }.count == 9 && winner == nil
    }
}
