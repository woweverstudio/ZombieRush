import SwiftUI

// MARK: - Color Extensions
extension Color {
    /// 마젠타 색상 (네온 핑크)
    static let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)

    /// 시안 색상 (네온 블루)
//    static let cyan = Color(red: 0.0, green: 0.8, blue: 1.0)

    /// 네온 옐로우 색상
    static let neonYellow = Color(red: 1.0, green: 0.8, blue: 0.0)

    /// 헥사코드로부터 Color 생성
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
