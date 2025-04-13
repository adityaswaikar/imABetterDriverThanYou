import SwiftUI

struct AppTheme {
    // Colors
    static let primary = Color(red: 0.0, green: 0.48, blue: 0.8)
    static let secondary = Color(red: 0.31, green: 0.64, blue: 0.99)
    static let accent = Color(red: 0.0, green: 0.8, blue: 0.6)
    static let warning = Color(red: 0.95, green: 0.61, blue: 0.07)
    static let danger = Color(red: 0.93, green: 0.25, blue: 0.25)
    static let success = Color(red: 0.18, green: 0.8, blue: 0.44)
    
    // Text Styles
    struct TextStyle {
        static let header = Font.system(size: 28, weight: .bold)
        static let title = Font.system(size: 22, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 14, weight: .medium)
    }
    
    // Card Styles
    struct CardStyle {
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 5
        static let padding: CGFloat = 16
    }
}