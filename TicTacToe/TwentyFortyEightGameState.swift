//
//  TwentyFortyEightGameState.swift
//  GOMP
//
//  Created on 2/1/26.
//

import Foundation
import SwiftUI
import Combine

/// Game state for the 2048 puzzle game.
///
/// ## Gameplay
/// - Slide tiles in four directions (up, down, left, right)
/// - Adjacent tiles with the same value merge into one
/// - Merged value = sum of two tiles
/// - New tile (2 or 4) spawns after each move
/// - Win: Create a 2048 tile
/// - Lose: No empty cells and no valid moves
///
/// ## Algorithm
/// For each direction:
/// 1. Slide all tiles in that direction
/// 2. Merge adjacent tiles with same value
/// 3. Add random tile (90% = 2, 10% = 4)
/// 4. Check for win or game over
@MainActor
class TwentyFortyEightGameState: ObservableObject {
    enum Direction {
        case up, down, left, right
    }
    
    enum ColorScheme: String, CaseIterable, Identifiable {
        case classic = "Classic"
        case dark = "Dark Mode"
        case ocean = "Ocean"
        case sunset = "Sunset"
        case forest = "Forest"
        case candy = "Candy"
        
        var id: String { rawValue }
    }
    
    /// 4x4 grid of tiles. nil = empty cell
    @Published var grid: [[Int?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    
    /// Current score (sum of all merged tiles)
    @Published var score: Int = 0
    
    /// Best score ever achieved
    @Published var bestScore: Int = 0
    
    /// Whether game is over (no valid moves)
    @Published var isGameOver: Bool = false
    
    /// Whether player has won (created 2048 tile)
    @Published var hasWon: Bool = false
    
    /// Whether "You Win!" message has been shown
    @Published var hasShownWinMessage: Bool = false
    
    /// Number of moves made
    @Published var moveCount: Int = 0
    
    /// Whether undo is available
    @Published var canUndo: Bool = false
    
    /// Current color scheme
    @Published var colorScheme: ColorScheme = .classic
    
    /// Previous grid state (for undo)
    private var previousGrid: [[Int?]]?
    
    /// Previous score (for undo)
    private var previousScore: Int?
    
    /// Previous move count (for undo)
    private var previousMoveCount: Int?
    
    init() {
        loadBestScore()
        loadColorScheme()
        startNewGame()
    }
    
    /// Start a new game with 2 random tiles
    func startNewGame() {
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        score = 0
        isGameOver = false
        hasWon = false
        hasShownWinMessage = false
        moveCount = 0
        canUndo = false
        previousGrid = nil
        previousScore = nil
        previousMoveCount = nil
        
        // Add 2 random tiles to start
        addRandomTile()
        addRandomTile()
    }
    
    /// Attempt to move tiles in the specified direction
    /// Returns true if the grid changed
    @discardableResult
    func move(direction: Direction) -> Bool {
        guard !isGameOver else { return false }
        
        // Save state for undo (before the move)
        previousGrid = grid
        previousScore = score
        previousMoveCount = moveCount
        
        let oldGrid = grid
        
        // Perform the move
        switch direction {
        case .left:
            moveLeft()
        case .right:
            moveRight()
        case .up:
            moveUp()
        case .down:
            moveDown()
        }
        
        // Check if grid changed
        let gridChanged = grid != oldGrid
        
        if gridChanged {
            moveCount += 1
            
            // Add new tile
            addRandomTile()
            
            // Enable undo (user can undo this move)
            canUndo = true
            
            // Check win condition
            if !hasWon && hasReached2048() {
                hasWon = true
            }
            
            // Check game over
            if !hasEmptyCells() && !hasValidMoves() {
                isGameOver = true
            }
            
            // Update best score
            if score > bestScore {
                bestScore = score
                saveBestScore()
            }
        } else {
            // No change - restore undo state
            previousGrid = nil
            previousScore = nil
            previousMoveCount = nil
        }
        
        return gridChanged
    }
    
    /// Undo the last move
    func undo() {
        guard canUndo,
              let prevGrid = previousGrid,
              let prevScore = previousScore,
              let prevMoves = previousMoveCount else {
            return
        }
        
        // Restore previous state
        grid = prevGrid
        score = prevScore
        moveCount = prevMoves
        
        // Reset game over state (undo brings game back to playable state)
        isGameOver = false
        
        // Clear undo state
        canUndo = false
        previousGrid = nil
        previousScore = nil
        previousMoveCount = nil
    }
    
    // MARK: - Move Logic
    
    private func moveLeft() {
        for row in 0..<4 {
            var line = extractLine(row: row)
            line = slide(line)
            line = merge(line)
            line = slide(line) // Slide again after merge
            setLine(line, row: row)
        }
    }
    
    private func moveRight() {
        for row in 0..<4 {
            let line = extractLine(row: row)
            var reversed = Array(line.reversed())
            reversed = slide(reversed)
            reversed = merge(reversed)
            reversed = slide(reversed)
            setLine(Array(reversed.reversed()), row: row)
        }
    }
    
    private func moveUp() {
        for col in 0..<4 {
            var line = extractColumn(col: col)
            line = slide(line)
            line = merge(line)
            line = slide(line)
            setColumn(line, col: col)
        }
    }
    
    private func moveDown() {
        for col in 0..<4 {
            let line = extractColumn(col: col)
            var reversed = Array(line.reversed())
            reversed = slide(reversed)
            reversed = merge(reversed)
            reversed = slide(reversed)
            setColumn(Array(reversed.reversed()), col: col)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Extract a row from the grid
    private func extractLine(row: Int) -> [Int?] {
        return grid[row]
    }
    
    /// Set a row in the grid
    private func setLine(_ line: [Int?], row: Int) {
        grid[row] = line
    }
    
    /// Extract a column from the grid
    private func extractColumn(col: Int) -> [Int?] {
        return (0..<4).map { grid[$0][col] }
    }
    
    /// Set a column in the grid
    private func setColumn(_ line: [Int?], col: Int) {
        for row in 0..<4 {
            grid[row][col] = line[row]
        }
    }
    
    /// Slide all non-nil values to the left
    private func slide(_ line: [Int?]) -> [Int?] {
        let nonNil = line.compactMap { $0 }
        let nils = Array(repeating: nil as Int?, count: 4 - nonNil.count)
        return nonNil + nils
    }
    
    /// Merge adjacent equal values
    private func merge(_ line: [Int?]) -> [Int?] {
        var result = line
        for i in 0..<3 {
            if let val1 = result[i], let val2 = result[i+1], val1 == val2 {
                result[i] = val1 * 2
                result[i+1] = nil
                score += val1 * 2
            }
        }
        return result
    }
    
    /// Add a random tile (90% = 2, 10% = 4) to an empty cell
    private func addRandomTile() {
        let emptyCells = getEmptyCells()
        guard !emptyCells.isEmpty else { return }
        
        let randomCell = emptyCells.randomElement()!
        let value = Int.random(in: 0..<10) < 9 ? 2 : 4
        grid[randomCell.row][randomCell.col] = value
    }
    
    /// Get all empty cells (row, col)
    private func getEmptyCells() -> [(row: Int, col: Int)] {
        var cells: [(row: Int, col: Int)] = []
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == nil {
                    cells.append((row, col))
                }
            }
        }
        return cells
    }
    
    /// Check if there are any empty cells
    private func hasEmptyCells() -> Bool {
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == nil {
                    return true
                }
            }
        }
        return false
    }
    
    /// Check if there are any valid moves (horizontal or vertical merges possible)
    private func hasValidMoves() -> Bool {
        // Check horizontal merges
        for row in 0..<4 {
            for col in 0..<3 {
                if grid[row][col] == grid[row][col+1] {
                    return true
                }
            }
        }
        
        // Check vertical merges
        for col in 0..<4 {
            for row in 0..<3 {
                if grid[row][col] == grid[row+1][col] {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Check if player has reached 2048
    private func hasReached2048() -> Bool {
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == 2048 {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Persistence
    
    private func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: "TwentyFortyEight_BestScore")
    }
    
    private func saveBestScore() {
        UserDefaults.standard.set(bestScore, forKey: "TwentyFortyEight_BestScore")
    }
    
    private func loadColorScheme() {
        if let saved = UserDefaults.standard.string(forKey: "TwentyFortyEight_ColorScheme"),
           let scheme = ColorScheme(rawValue: saved) {
            colorScheme = scheme
        }
    }
    
    func saveColorScheme() {
        UserDefaults.standard.set(colorScheme.rawValue, forKey: "TwentyFortyEight_ColorScheme")
    }
}

// MARK: - Color Scheme Definitions

extension TwentyFortyEightGameState.ColorScheme {
    /// Get tile color for a given value
    func tileColor(for value: Int?) -> Color {
        guard let value = value else { return .clear }
        
        switch self {
        case .classic:
            return classicColors[value] ?? Color(hex: "3c3a32")
        case .dark:
            return darkColors[value] ?? Color(hex: "1a1a1a")
        case .ocean:
            return oceanColors[value] ?? Color(hex: "0a3d62")
        case .sunset:
            return sunsetColors[value] ?? Color(hex: "d63031")
        case .forest:
            return forestColors[value] ?? Color(hex: "0b6623")
        case .candy:
            return candyColors[value] ?? Color(hex: "e84393")
        }
    }
    
    /// Get text color for a given value
    func textColor(for value: Int?) -> Color {
        guard let value = value else { return .clear }
        
        switch self {
        case .classic:
            return value <= 4 ? Color(hex: "776e65") : .white
        case .dark:
            return .white
        case .ocean:
            return value <= 4 ? Color(hex: "0a3d62") : .white
        case .sunset:
            return value <= 4 ? Color(hex: "5f3a22") : .white
        case .forest:
            return value <= 4 ? Color(hex: "0b6623") : .white
        case .candy:
            return .white
        }
    }
    
    // Classic (original 2048 colors)
    private var classicColors: [Int: Color] {
        [
            2: Color(hex: "eee4da"),
            4: Color(hex: "ede0c8"),
            8: Color(hex: "f2b179"),
            16: Color(hex: "f59563"),
            32: Color(hex: "f67c5f"),
            64: Color(hex: "f65e3b"),
            128: Color(hex: "edcf72"),
            256: Color(hex: "edcc61"),
            512: Color(hex: "edc850"),
            1024: Color(hex: "edc53f"),
            2048: Color(hex: "edc22e")
        ]
    }
    
    // Dark Mode
    private var darkColors: [Int: Color] {
        [
            2: Color(hex: "2d2d2d"),
            4: Color(hex: "3d3d3d"),
            8: Color(hex: "4d4d4d"),
            16: Color(hex: "5d5d5d"),
            32: Color(hex: "6d6d6d"),
            64: Color(hex: "7d7d7d"),
            128: Color(hex: "8d8d8d"),
            256: Color(hex: "9d9d9d"),
            512: Color(hex: "adadad"),
            1024: Color(hex: "bdbdbd"),
            2048: Color(hex: "cdcdcd")
        ]
    }
    
    // Ocean (blue tones)
    private var oceanColors: [Int: Color] {
        [
            2: Color(hex: "dfe6e9"),
            4: Color(hex: "b2bec3"),
            8: Color(hex: "74b9ff"),
            16: Color(hex: "0984e3"),
            32: Color(hex: "00b894"),
            64: Color(hex: "00cec9"),
            128: Color(hex: "6c5ce7"),
            256: Color(hex: "a29bfe"),
            512: Color(hex: "fd79a8"),
            1024: Color(hex: "fdcb6e"),
            2048: Color(hex: "ffeaa7")
        ]
    }
    
    // Sunset (warm orange/pink)
    private var sunsetColors: [Int: Color] {
        [
            2: Color(hex: "fff5e6"),
            4: Color(hex: "ffe4cc"),
            8: Color(hex: "ffc299"),
            16: Color(hex: "ff9966"),
            32: Color(hex: "ff7033"),
            64: Color(hex: "ff4500"),
            128: Color(hex: "ff1a75"),
            256: Color(hex: "e600ac"),
            512: Color(hex: "cc00cc"),
            1024: Color(hex: "9900cc"),
            2048: Color(hex: "6600cc")
        ]
    }
    
    // Forest (green tones)
    private var forestColors: [Int: Color] {
        [
            2: Color(hex: "e8f5e9"),
            4: Color(hex: "c8e6c9"),
            8: Color(hex: "a5d6a7"),
            16: Color(hex: "81c784"),
            32: Color(hex: "66bb6a"),
            64: Color(hex: "4caf50"),
            128: Color(hex: "43a047"),
            256: Color(hex: "388e3c"),
            512: Color(hex: "2e7d32"),
            1024: Color(hex: "1b5e20"),
            2048: Color(hex: "0d3d10")
        ]
    }
    
    // Candy (vibrant/playful)
    private var candyColors: [Int: Color] {
        [
            2: Color(hex: "ffccff"),
            4: Color(hex: "ff99ff"),
            8: Color(hex: "ff66ff"),
            16: Color(hex: "ff33ff"),
            32: Color(hex: "ff00ff"),
            64: Color(hex: "cc00ff"),
            128: Color(hex: "9900ff"),
            256: Color(hex: "6600ff"),
            512: Color(hex: "3300ff"),
            1024: Color(hex: "0000ff"),
            2048: Color(hex: "0000cc")
        ]
    }
}

