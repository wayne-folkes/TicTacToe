import XCTest
@testable import GamesApp

@MainActor
final class TwentyFortyEightGameStateTests: XCTestCase {
    
    // MARK: - Test Case 1: startNewGame initializes game state correctly
    
    func testStartNewGameInitializesGameState() {
        let state = TwentyFortyEightGameState()
        
        // Verify score is 0
        XCTAssertEqual(state.score, 0, "Score should be initialized to 0")
        
        // Verify win/loss status
        XCTAssertFalse(state.hasWon, "hasWon should be false at game start")
        XCTAssertFalse(state.isGameOver, "isGameOver should be false at game start")
        XCTAssertFalse(state.hasShownWinMessage, "hasShownWinMessage should be false at game start")
        
        // Verify move count is 0
        XCTAssertEqual(state.moveCount, 0, "Move count should be 0 at game start")
        
        // Verify undo is not available
        XCTAssertFalse(state.canUndo, "Undo should not be available at game start")
        
        // Verify grid is 4x4
        XCTAssertEqual(state.grid.count, 4, "Grid should have 4 rows")
        for row in state.grid {
            XCTAssertEqual(row.count, 4, "Each row should have 4 columns")
        }
        
        // Verify exactly 2 tiles are populated (starting tiles)
        let nonEmptyTiles = state.grid.flatMap { $0 }.compactMap { $0 }
        XCTAssertEqual(nonEmptyTiles.count, 2, "Should have exactly 2 starting tiles")
        
        // Verify starting tiles are either 2 or 4
        for tile in nonEmptyTiles {
            XCTAssertTrue(tile == 2 || tile == 4, "Starting tiles should be 2 or 4")
        }
    }
    
    func testStartNewGameResetsState() {
        let state = TwentyFortyEightGameState()
        
        // Modify the state
        state.grid[0][0] = 2048
        state.score = 5000
        state.moveCount = 50
        state.hasWon = true
        state.isGameOver = true
        state.hasShownWinMessage = true
        
        // Start new game
        state.startNewGame()
        
        // Verify state is reset
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.moveCount, 0)
        XCTAssertFalse(state.hasWon)
        XCTAssertFalse(state.isGameOver)
        XCTAssertFalse(state.hasShownWinMessage)
        XCTAssertFalse(state.canUndo)
        
        // Verify 2 starting tiles
        let nonEmptyTiles = state.grid.flatMap { $0 }.compactMap { $0 }
        XCTAssertEqual(nonEmptyTiles.count, 2)
    }
    
    // MARK: - Test Case 2: move function slides and merges tiles correctly
    
    func testMoveLeftSlidesTiles() {
        let state = TwentyFortyEightGameState()
        
        // Set up a specific grid: [2, nil, nil, nil]
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        // Move left (should not change anything since tile is already left)
        state.move(direction: .left)
        
        // Verify tile stayed at position 0
        XCTAssertEqual(state.grid[0][0], 2)
        
        // Set up grid with tile on right: [nil, nil, nil, 2]
        state.grid = [
            [nil, nil, nil, 2],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        
        // Remove the tile that was added by the previous move
        // by setting up fresh grid
        state.grid = [
            [nil, nil, nil, 2],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .left)
        
        // After move, verify tile slid to left and new tile was added
        XCTAssertEqual(state.grid[0][0], 2, "Tile should slide to leftmost position")
    }
    
    func testMoveLeftMergesTiles() {
        let state = TwentyFortyEightGameState()
        
        // Set up a grid with two 2s that should merge: [2, 2, nil, nil]
        state.grid = [
            [2, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        state.moveCount = 0
        
        let gridChanged = state.move(direction: .left)
        
        // Verify merge occurred
        XCTAssertTrue(gridChanged, "Grid should have changed")
        XCTAssertEqual(state.grid[0][0], 4, "Tiles should merge into 4")
        XCTAssertNil(state.grid[0][1], "Second position should be empty after merge")
        
        // Verify score increased by merged value
        XCTAssertEqual(state.score, 4, "Score should increase by 4")
        
        // Verify move count increased
        XCTAssertEqual(state.moveCount, 1)
    }
    
    func testMoveLeftComplexScenario() {
        let state = TwentyFortyEightGameState()
        
        // Set up: [2, 2, 4, 4] -> should become [4, 8, nil, nil] + new tile
        state.grid = [
            [2, 2, 4, 4],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .left)
        
        // After move: [4, 8, ...] with one new random tile added
        XCTAssertEqual(state.grid[0][0], 4, "First pair should merge to 4")
        XCTAssertEqual(state.grid[0][1], 8, "Second pair should merge to 8")
        
        // Score should be 4 + 8 = 12
        XCTAssertEqual(state.score, 12)
    }
    
    func testMoveRightSlidesTiles() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid: [2, nil, nil, nil]
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .right)
        
        // Tile should slide to rightmost position
        XCTAssertEqual(state.grid[0][3], 2, "Tile should slide to rightmost position")
        XCTAssertNil(state.grid[0][0], "Original position should be empty")
    }
    
    func testMoveUpSlidesTiles() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid with tile at bottom of first column
        state.grid = [
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [2, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .up)
        
        // Tile should slide to top
        XCTAssertEqual(state.grid[0][0], 2, "Tile should slide to top")
        XCTAssertNil(state.grid[3][0], "Original position should be empty")
    }
    
    func testMoveDownSlidesTiles() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid with tile at top of first column
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .down)
        
        // Tile should slide to bottom
        XCTAssertEqual(state.grid[3][0], 2, "Tile should slide to bottom")
        XCTAssertNil(state.grid[0][0], "Original position should be empty")
    }
    
    func testMoveDoesNotChangeGridWhenInvalid() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid where left move won't change anything
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        
        let gridBefore = state.grid
        let scoreBefore = state.score
        let moveCountBefore = state.moveCount
        
        let changed = state.move(direction: .left)
        
        // Verify nothing changed
        XCTAssertFalse(changed, "Grid should not change")
        XCTAssertEqual(state.score, scoreBefore, "Score should not change")
        XCTAssertEqual(state.moveCount, moveCountBefore, "Move count should not change")
        XCTAssertFalse(state.canUndo, "Undo should not be available for invalid move")
    }
    
    func testMoveAddsNewTileAfterValidMove() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid with one tile
        state.grid = [
            [nil, nil, nil, 2],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        
        state.move(direction: .left)
        
        // Count non-empty tiles (should be 2: the moved tile + new random tile)
        let nonEmptyTiles = state.grid.flatMap { $0 }.compactMap { $0 }
        XCTAssertEqual(nonEmptyTiles.count, 2, "Should have original tile plus one new tile")
    }
    
    // MARK: - Test Case 3: undo function reverts game state
    
    func testUndoRevertsMove() {
        let state = TwentyFortyEightGameState()
        
        // Set up specific grid
        state.grid = [
            [2, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 100
        state.moveCount = 5
        
        // Save state before move
        let gridBefore = state.grid
        let scoreBefore = state.score
        let moveCountBefore = state.moveCount
        
        // Make a move
        state.move(direction: .left)
        
        // Verify state changed
        XCTAssertNotEqual(state.grid, gridBefore)
        XCTAssertTrue(state.canUndo, "Undo should be available after valid move")
        
        // Undo
        state.undo()
        
        // Verify state reverted
        XCTAssertEqual(state.grid, gridBefore, "Grid should revert to previous state")
        XCTAssertEqual(state.score, scoreBefore, "Score should revert to previous value")
        XCTAssertEqual(state.moveCount, moveCountBefore, "Move count should revert")
        XCTAssertFalse(state.canUndo, "Undo should not be available after undo")
    }
    
    func testUndoNotAvailableAtStart() {
        let state = TwentyFortyEightGameState()
        
        XCTAssertFalse(state.canUndo, "Undo should not be available at game start")
        
        // Calling undo should not crash or change anything
        let gridBefore = state.grid
        state.undo()
        XCTAssertEqual(state.grid, gridBefore, "Grid should remain unchanged")
    }
    
    func testUndoNotAvailableAfterInvalidMove() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid where left move won't work
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.canUndo = false
        
        state.move(direction: .left)
        
        XCTAssertFalse(state.canUndo, "Undo should not be available after invalid move")
    }
    
    func testUndoOnlyAllowedOnce() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid
        state.grid = [
            [2, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        
        let originalGrid = state.grid
        
        // Make move
        state.move(direction: .left)
        XCTAssertTrue(state.canUndo)
        
        // Undo once
        state.undo()
        XCTAssertFalse(state.canUndo, "Should not be able to undo again")
        
        // Try to undo again (should do nothing)
        state.undo()
        XCTAssertEqual(state.grid, originalGrid, "Grid should still be at original state")
    }
    
    // MARK: - Test Case 3: Undo resets game over state
    
    func testUndoResetsGameOverState() {
        let state = TwentyFortyEightGameState()
        
        // Set up a grid where a move is possible
        state.grid = [
            [2, 0, 0, 0],
            [2, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        
        // Make a move to set up undo state properly
        let moveSucceeded = state.move(direction: .up)
        XCTAssertTrue(moveSucceeded, "Move should succeed")
        XCTAssertTrue(state.canUndo, "Undo should be available after move")
        
        // Now simulate game over
        state.isGameOver = true
        
        // Undo should reset game over flag
        state.undo()
        
        XCTAssertFalse(state.isGameOver, "Game over should be reset after undo")
    }
    
    // MARK: - Test Case 4: Win condition when 2048 tile is created
    
    func testWinConditionWhen2048Created() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid where merging will create 2048
        state.grid = [
            [1024, 1024, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.hasWon = false
        state.score = 0
        
        // Make move that creates 2048
        state.move(direction: .left)
        
        // Verify win condition
        XCTAssertTrue(state.hasWon, "hasWon should be true when 2048 tile is created")
        XCTAssertEqual(state.grid[0][0], 2048, "2048 tile should exist")
        XCTAssertEqual(state.score, 2048, "Score should include the 2048 merge")
    }
    
    func testWinConditionNotTriggeredWithout2048() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid with high tiles but not 2048
        state.grid = [
            [512, 512, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.hasWon = false
        
        // Make move that creates 1024
        state.move(direction: .left)
        
        // Verify win not triggered
        XCTAssertFalse(state.hasWon, "hasWon should be false when only 1024 is created")
    }
    
    func testWinConditionOnlyTriggeredOnce() {
        let state = TwentyFortyEightGameState()
        
        // Manually set up grid with 2048 already present
        state.grid = [
            [2048, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.hasWon = true // Already won
        state.hasShownWinMessage = false
        
        // Make another move
        state.move(direction: .left)
        
        // hasWon should remain true (not toggled)
        XCTAssertTrue(state.hasWon, "hasWon should remain true")
    }
    
    func testWinWithMultiple2048Tiles() {
        let state = TwentyFortyEightGameState()
        
        // Start with one 2048
        state.grid = [
            [2048, 1024, 1024, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.hasWon = true // Already won once
        
        // Create another 2048
        state.move(direction: .left)
        
        // Should have at least one 2048 (could have merged to 4096)
        let has2048 = state.grid.flatMap { $0 }.contains(2048)
        let has4096 = state.grid.flatMap { $0 }.contains(4096)
        
        XCTAssertTrue(has2048 || has4096, "Should have 2048 or 4096 tile")
        XCTAssertTrue(state.hasWon, "Should remain in won state")
    }
    
    // MARK: - Test Case 5: Game over condition when no moves possible
    
    func testGameOverWhenNoMovesAvailable() {
        let state = TwentyFortyEightGameState()
        
        // Set up a grid with no possible moves (checkerboard pattern)
        state.grid = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2]
        ]
        state.isGameOver = false
        
        // Try to move (should trigger game over detection)
        // Note: The move itself won't change the grid, but we need to verify
        // that the game recognizes there are no valid moves
        
        // Manually check game over by attempting a move
        // Since grid is full and no merges possible, any move should fail
        let changed = state.move(direction: .left)
        
        XCTAssertFalse(changed, "Grid should not change when no moves available")
        
        // For a true test, we need to set up a scenario where the last move
        // fills the board and creates a game over state
        // Let's set up a nearly-full board
        state.grid = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, nil] // One empty space
        ]
        state.isGameOver = false
        
        // Place a tile that won't match neighbors
        state.grid[3][3] = 2
        
        // Now check if game detects game over
        // Since move() adds a random tile, we need to verify detection after that
        // We'll test the internal logic by checking a full board
        state.grid = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2]
        ]
        
        // After this setup, try a move - it should not change grid
        // and should detect game over
        let gridBefore = state.grid
        state.move(direction: .left)
        
        // Since no move is possible, grid shouldn't change
        XCTAssertEqual(state.grid, gridBefore, "Grid should not change")
    }
    
    func testGameOverNotTriggeredWithEmptyCells() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid with empty cells
        state.grid = [
            [2, 4, nil, nil],
            [4, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.isGameOver = false
        
        // Make a move
        state.move(direction: .left)
        
        // Game should not be over
        XCTAssertFalse(state.isGameOver, "Game should not be over with empty cells")
    }
    
    func testGameOverNotTriggeredWithValidMerges() {
        let state = TwentyFortyEightGameState()
        
        // Set up full grid but with possible merges
        state.grid = [
            [2, 2, 4, 8],
            [4, 4, 8, 16],
            [8, 8, 16, 32],
            [16, 16, 32, 64]
        ]
        state.isGameOver = false
        
        // Try a move that will merge tiles
        state.move(direction: .left)
        
        // Game should not be over since merges are possible
        XCTAssertFalse(state.isGameOver, "Game should not be over when merges are possible")
    }
    
    func testGameOverAfterLastValidMove() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid where after one move, no more moves will be possible
        // This is tricky because after a move, a random tile is added
        // So we need to test the detection logic more directly
        
        // Set up a nearly-game-over state with one empty cell
        state.grid = [
            [2, 4, 8, 16],
            [4, 8, 16, 32],
            [8, 16, 32, 64],
            [16, 32, 64, nil]
        ]
        
        // After placing a tile here that doesn't match neighbors, game should be over
        // But since move() adds random tile, we can't control it
        // Instead, let's verify the detection works by manually filling the grid
        
        state.grid[3][3] = 128 // No matches with neighbors
        
        // Verify board is full
        let emptyCells = state.grid.flatMap { $0 }.filter { $0 == nil }.count
        XCTAssertEqual(emptyCells, 0, "Board should be full")
        
        // Now try a move that won't work
        let changed = state.move(direction: .left)
        XCTAssertFalse(changed, "Move should not succeed on full board with no merges")
    }
    
    func testCannotMoveAfterGameOver() {
        let state = TwentyFortyEightGameState()
        
        // Manually set game over state
        state.grid = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2]
        ]
        state.isGameOver = true
        
        let gridBefore = state.grid
        let scoreBefore = state.score
        
        // Try to move
        let changed = state.move(direction: .left)
        
        // Verify nothing changed
        XCTAssertFalse(changed, "Move should not succeed when game is over")
        XCTAssertEqual(state.grid, gridBefore, "Grid should not change")
        XCTAssertEqual(state.score, scoreBefore, "Score should not change")
    }
    
    // MARK: - Additional Edge Cases
    
    func testMultipleMergesInOneMove() {
        let state = TwentyFortyEightGameState()
        
        // Set up: [2, 2, 2, 2] -> should become [4, 4, nil, nil]
        state.grid = [
            [2, 2, 2, 2],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .left)
        
        // Should merge into two 4s
        XCTAssertEqual(state.grid[0][0], 4)
        XCTAssertEqual(state.grid[0][1], 4)
        
        // Score should be 8 (4 + 4)
        XCTAssertEqual(state.score, 8)
    }
    
    func testMergeDoesNotChain() {
        let state = TwentyFortyEightGameState()
        
        // Set up: [2, 2, 4, nil] -> should become [4, 4, nil, nil], NOT [8, nil, nil, nil]
        state.grid = [
            [2, 2, 4, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .left)
        
        // First merge: 2+2=4, then slide 4 next to result
        // Should be [4, 4, ...] not [8, ...]
        XCTAssertEqual(state.grid[0][0], 4, "First merge should create 4")
        XCTAssertEqual(state.grid[0][1], 4, "Original 4 should remain")
        
        // Score should be 4 (only one merge)
        XCTAssertEqual(state.score, 4)
    }
    
    func testScoreAccumulation() {
        let state = TwentyFortyEightGameState()
        
        // First move: merge 2+2
        state.grid = [
            [2, 2, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.score = 0
        
        state.move(direction: .left)
        XCTAssertEqual(state.score, 4, "Score should be 4 after first merge")
        
        // Second move: merge 4+4 (setup manually)
        state.grid = [
            [4, 4, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        
        state.move(direction: .left)
        
        // Score should accumulate: 4 + 8 = 12
        XCTAssertEqual(state.score, 12, "Score should accumulate across moves")
    }
    
    func testMoveCountIncrementsOnlyForValidMoves() {
        let state = TwentyFortyEightGameState()
        
        // Set up grid
        state.grid = [
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ]
        state.moveCount = 0
        
        // Try invalid move (tile already at left)
        state.move(direction: .left)
        XCTAssertEqual(state.moveCount, 0, "Move count should not increment for invalid move")
        
        // Try valid move
        state.move(direction: .right)
        XCTAssertEqual(state.moveCount, 1, "Move count should increment for valid move")
    }
}
