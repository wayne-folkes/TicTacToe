import SwiftUI
import Combine

enum Player: String {
    case x = "X"
    case o = "O"
}

@MainActor
class TicTacToeGameState: ObservableObject {
    @Published var board: [Player?]
    @Published var currentPlayer: Player
    @Published var winner: Player?
    @Published var isDraw: Bool
    
    init() {
        self.board = Array(repeating: nil, count: 9)
        self.currentPlayer = .x
        self.winner = nil
        self.isDraw = false
    }
    
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
    
    func resetGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .x
        winner = nil
        isDraw = false
    }
    
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
    
    private func checkDraw() -> Bool {
        return board.compactMap { $0 }.count == 9 && winner == nil
    }
}
