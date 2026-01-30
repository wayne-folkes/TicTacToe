import XCTest
@testable import GamesApp

@MainActor
final class TicTacToeGameStateTests: XCTestCase {
    func testInitialization() {
        let state = TicTacToeGameState()
        
        XCTAssertEqual(state.board.count, 9)
        XCTAssertTrue(state.board.allSatisfy { $0 == nil })
        XCTAssertEqual(state.currentPlayer, .x)
        XCTAssertNil(state.winner)
        XCTAssertFalse(state.isDraw)
    }
    
    func testMakeMove() {
        let state = TicTacToeGameState()
        
        state.makeMove(at: 0)
        
        XCTAssertEqual(state.board[0], .x)
        XCTAssertEqual(state.currentPlayer, .o)
        XCTAssertNil(state.winner)
        XCTAssertFalse(state.isDraw)
    }
    
    func testTurnSwitching() {
        let state = TicTacToeGameState()
        
        state.makeMove(at: 0) // X
        XCTAssertEqual(state.currentPlayer, .o)
        
        state.makeMove(at: 1) // O
        XCTAssertEqual(state.currentPlayer, .x)
        
        state.makeMove(at: 2) // X
        XCTAssertEqual(state.currentPlayer, .o)
    }
    
    func testCannotMoveOnOccupiedSquare() {
        let state = TicTacToeGameState()
        
        state.makeMove(at: 0) // X
        let playerAfterFirstMove = state.currentPlayer
        
        state.makeMove(at: 0) // Try to move on same square
        
        // Board shouldn't change and player shouldn't switch
        XCTAssertEqual(state.board[0], .x)
        XCTAssertEqual(state.currentPlayer, playerAfterFirstMove)
    }
    
    func testHorizontalWinTopRow() {
        let state = TicTacToeGameState()
        
        // X wins top row
        state.makeMove(at: 0) // X
        state.makeMove(at: 3) // O
        state.makeMove(at: 1) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 2) // X wins!
        
        XCTAssertEqual(state.winner, .x)
        XCTAssertFalse(state.isDraw)
    }
    
    func testHorizontalWinMiddleRow() {
        let state = TicTacToeGameState()
        
        // O wins middle row
        state.makeMove(at: 0) // X
        state.makeMove(at: 3) // O
        state.makeMove(at: 1) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 6) // X
        state.makeMove(at: 5) // O wins!
        
        XCTAssertEqual(state.winner, .o)
        XCTAssertFalse(state.isDraw)
    }
    
    func testHorizontalWinBottomRow() {
        let state = TicTacToeGameState()
        
        // X wins bottom row
        state.makeMove(at: 6) // X
        state.makeMove(at: 0) // O
        state.makeMove(at: 7) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 8) // X wins!
        
        XCTAssertEqual(state.winner, .x)
    }
    
    func testVerticalWinLeftColumn() {
        let state = TicTacToeGameState()
        
        // X wins left column
        state.makeMove(at: 0) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 3) // X
        state.makeMove(at: 2) // O
        state.makeMove(at: 6) // X wins!
        
        XCTAssertEqual(state.winner, .x)
    }
    
    func testVerticalWinMiddleColumn() {
        let state = TicTacToeGameState()
        
        // O wins middle column
        state.makeMove(at: 0) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 2) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 5) // X
        state.makeMove(at: 7) // O wins!
        
        XCTAssertEqual(state.winner, .o)
    }
    
    func testVerticalWinRightColumn() {
        let state = TicTacToeGameState()
        
        // X wins right column
        state.makeMove(at: 2) // X
        state.makeMove(at: 0) // O
        state.makeMove(at: 5) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 8) // X wins!
        
        XCTAssertEqual(state.winner, .x)
    }
    
    func testDiagonalWinTopLeftToBottomRight() {
        let state = TicTacToeGameState()
        
        // X wins diagonal
        state.makeMove(at: 0) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 4) // X
        state.makeMove(at: 2) // O
        state.makeMove(at: 8) // X wins!
        
        XCTAssertEqual(state.winner, .x)
        XCTAssertFalse(state.isDraw)
    }
    
    func testDiagonalWinTopRightToBottomLeft() {
        let state = TicTacToeGameState()
        
        // O wins diagonal
        state.makeMove(at: 0) // X
        state.makeMove(at: 2) // O
        state.makeMove(at: 1) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 5) // X
        state.makeMove(at: 6) // O wins!
        
        XCTAssertEqual(state.winner, .o)
        XCTAssertFalse(state.isDraw)
    }
    
    func testDrawGame() {
        let state = TicTacToeGameState()
        
        // Create a draw scenario
        // X O X
        // X O X
        // O X O
        state.makeMove(at: 0) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 2) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 3) // X
        state.makeMove(at: 5) // O (block)
        state.makeMove(at: 7) // X
        state.makeMove(at: 6) // O
        state.makeMove(at: 8) // X
        
        XCTAssertTrue(state.isDraw)
        XCTAssertNil(state.winner)
    }
    
    func testCannotMoveAfterWin() {
        let state = TicTacToeGameState()
        
        // X wins
        state.makeMove(at: 0) // X
        state.makeMove(at: 3) // O
        state.makeMove(at: 1) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 2) // X wins!
        
        let boardCopy = state.board
        
        // Try to make another move
        state.makeMove(at: 5)
        
        // Board should not change
        XCTAssertEqual(state.board, boardCopy)
    }
    
    func testCannotMoveAfterDraw() {
        let state = TicTacToeGameState()
        
        // Create a draw
        state.makeMove(at: 0) // X
        state.makeMove(at: 1) // O
        state.makeMove(at: 2) // X
        state.makeMove(at: 4) // O
        state.makeMove(at: 3) // X
        state.makeMove(at: 5) // O
        state.makeMove(at: 7) // X
        state.makeMove(at: 6) // O
        state.makeMove(at: 8) // X - Draw
        
        XCTAssertTrue(state.isDraw)
        
        // Board should be full
        XCTAssertTrue(state.board.allSatisfy { $0 != nil })
    }
    
    func testResetGame() {
        let state = TicTacToeGameState()
        
        // Play a few moves
        state.makeMove(at: 0)
        state.makeMove(at: 1)
        state.makeMove(at: 2)
        
        state.resetGame()
        
        // Should be back to initial state
        XCTAssertTrue(state.board.allSatisfy { $0 == nil })
        XCTAssertEqual(state.currentPlayer, .x)
        XCTAssertNil(state.winner)
        XCTAssertFalse(state.isDraw)
    }
    
    func testResetGameAfterWin() {
        let state = TicTacToeGameState()
        
        // X wins
        state.makeMove(at: 0)
        state.makeMove(at: 3)
        state.makeMove(at: 1)
        state.makeMove(at: 4)
        state.makeMove(at: 2)
        
        XCTAssertEqual(state.winner, .x)
        
        state.resetGame()
        
        XCTAssertTrue(state.board.allSatisfy { $0 == nil })
        XCTAssertEqual(state.currentPlayer, .x)
        XCTAssertNil(state.winner)
        XCTAssertFalse(state.isDraw)
    }
}
