import SwiftUI

/// Extension to provide adaptive colors that work well in both light and dark mode
extension Color {
    /// Primary background for cards and buttons
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.2, alpha: 0.8) 
                : UIColor(white: 1.0, alpha: 0.6)
        })
    }
}
