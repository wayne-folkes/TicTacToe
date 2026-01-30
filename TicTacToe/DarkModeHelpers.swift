import SwiftUI

/// Extension to provide adaptive colors that work well in both light and dark mode
extension Color {
    /// A color that adapts to the color scheme - darker in light mode, lighter in dark mode
    static func adaptiveBackground(lightColor: Color, darkColor: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(darkColor) : UIColor(lightColor)
        })
    }
    
    /// Primary background for cards and buttons
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.2, alpha: 0.8) 
                : UIColor(white: 1.0, alpha: 0.6)
        })
    }
    
    /// Secondary background with more opacity
    static var secondaryCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.15, alpha: 0.9) 
                : UIColor(white: 1.0, alpha: 0.8)
        })
    }
    
    /// Text color that ensures readability
    static var adaptiveText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white 
                : UIColor.black
        })
    }
    
    /// Secondary text with reduced emphasis
    static var adaptiveSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.8, alpha: 1.0) 
                : UIColor(white: 0.3, alpha: 1.0)
        })
    }
}

/// Helper views for consistent dark mode support
struct AdaptiveCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(15)
            .shadow(radius: 3)
    }
}
