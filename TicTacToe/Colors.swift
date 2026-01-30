//
//  Colors.swift
//  TicTacToe
//
//  Created by Wayne Folkes on 1/30/26.
//

import SwiftUI

/// Semantic color definitions following Apple HIG.
///
/// All colors adapt automatically to light/dark mode and provide
/// consistent branding across the app while maintaining accessibility.
extension Color {
    // MARK: - Game Accent Colors
    
    /// Accent color for Tic-Tac-Toe game
    static let ticTacToeAccent = Color.blue
    
    /// Accent color for Memory game
    static let memoryAccent = Color.purple
    
    /// Accent color for Dictionary game
    static let dictionaryAccent = Color.green
    
    /// Accent color for Hangman game
    static let hangmanAccent = Color.orange
    
    // MARK: - Player Colors
    
    /// Color for player X in Tic-Tac-Toe
    static let playerX = Color.blue
    
    /// Color for player O in Tic-Tac-Toe
    static let playerO = Color.red
    
    // MARK: - State Colors
    
    /// Color for success states (correct answers, wins)
    static let successColor = Color.green
    
    /// Color for error states (incorrect answers, losses)
    static let errorColor = Color.red
    
    /// Color for warning states
    static let warningColor = Color.orange
    
    // MARK: - Background Colors
    
    /// Card background color (adapts to light/dark mode)
    static var cardBackground: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    /// Elevated card background (for cards on cards)
    static var elevatedCardBackground: Color {
        #if os(iOS)
        return Color(.tertiarySystemBackground)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
    
    // MARK: - Border Colors
    
    /// Standard border color for cards and UI elements
    static var borderColor: Color {
        #if os(iOS)
        return Color(.separator)
        #else
        return Color.gray.opacity(0.3)
        #endif
    }
    
    /// Subtle border color for less prominent elements
    static var subtleBorder: Color {
        #if os(iOS)
        return Color(.tertiarySystemFill)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
}
