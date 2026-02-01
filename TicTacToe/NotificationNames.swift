//
//  NotificationNames.swift
//  GOMP
//
//  Created on 2/1/26.
//

import Foundation

// MARK: - Notification Names
extension Notification.Name {
    static let newGame = Notification.Name("newGame")
    static let resetStats = Notification.Name("resetStats")
    static let toggleSound = Notification.Name("toggleSound")
    static let switchToGame = Notification.Name("switchToGame")
    static let showKeyboardShortcuts = Notification.Name("showKeyboardShortcuts")
}
