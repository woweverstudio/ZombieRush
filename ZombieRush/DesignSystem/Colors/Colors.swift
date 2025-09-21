import SwiftUI

// MARK: - Color Palette
public struct DesignSystemColors {
    // MARK: - Neon Colors
    public static let cyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    public static let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
    public static let neonYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
    public static let orange = Color(red: 0.5, green: 1.0, blue: 0.3)

    // MARK: - UI Colors
    public static let primary = cyan
    public static let secondary = magenta
    public static let accent = neonYellow
    public static let success = Color.green
    public static let warning = orange
    public static let error = Color.red
    public static let disabled = Color.gray.opacity(0.5)

    // MARK: - Special Colors (for specific use cases)
    public static let coin = Color.yellow  // 코인/포인트 색상
    public static let energy = Color.orange  // 에너지 색상
    public static let health = Color.red  // 체력 색상

    // MARK: - Background Colors
    public static let background = Color.black
    public static let surface = Color.black.opacity(0.3)
    public static let card = Color.white.opacity(0.05)
    public static let overlay = Color.black.opacity(0.7)

    // MARK: - Text Colors
    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.8)
    public static let textDisabled = Color.gray.opacity(0.5)
}

// MARK: - Color Extensions
extension Color {
    // MARK: - Neon Colors (Backward Compatibility)
    /// 마젠타 색상 (네온 핑크)
    public static let magenta = DesignSystemColors.magenta

    /// 시안 색상 (네온 블루)
    public static let cyan = DesignSystemColors.cyan

    /// 네온 옐로우 색상
    public static let neonYellow = DesignSystemColors.neonYellow

    /// 네온 오렌지 색상
    public static let neonOrange = DesignSystemColors.orange

    // MARK: - Design System Colors
    public static let dsPrimary = DesignSystemColors.primary
    public static let dsSecondary = DesignSystemColors.secondary
    public static let dsAccent = DesignSystemColors.accent
    public static let dsSuccess = DesignSystemColors.success
    public static let dsWarning = DesignSystemColors.warning
    public static let dsError = DesignSystemColors.error
    public static let dsDisabled = DesignSystemColors.disabled

    // MARK: - Special Colors
    public static let dsCoin = DesignSystemColors.coin
    public static let dsEnergy = DesignSystemColors.energy
    public static let dsHealth = DesignSystemColors.health

    // MARK: - Common Colors (for easy migration)
    public static let white = Color.white
    public static let yellow = Color.yellow

    // MARK: - Background Colors
    public static let dsBackground = DesignSystemColors.background
    public static let dsSurface = DesignSystemColors.surface
    public static let dsCard = DesignSystemColors.card
    public static let dsOverlay = DesignSystemColors.overlay

    // MARK: - Text Colors
    public static let dsTextPrimary = DesignSystemColors.textPrimary
    public static let dsTextSecondary = DesignSystemColors.textSecondary
    public static let dsTextDisabled = DesignSystemColors.textDisabled

    // MARK: - Hex Color Initializer
    /// 헥사코드로부터 Color 생성
    public init(hex: String) {
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

// MARK: - Color Style Enum (for Components)
public enum ColorStyle {
    case cyan
    case magenta
    case white
    case yellow
    case orange
    case gray
    case disabled

    public var color: Color {
        switch self {
        case .cyan:
            return DesignSystemColors.cyan
        case .magenta:
            return DesignSystemColors.magenta
        case .white:
            return Color.white
        case .yellow:
            return DesignSystemColors.neonYellow
        case .orange:
            return DesignSystemColors.orange
        case .gray:
            return Color.gray
        case .disabled:
            return DesignSystemColors.disabled
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            Circle().fill(Color.cyan).frame(width: 30, height: 30)
            Text("Cyan").foregroundColor(.cyan)
        }

        HStack(spacing: 10) {
            Circle().fill(Color.magenta).frame(width: 30, height: 30)
            Text("Magenta").foregroundColor(.magenta)
        }

        HStack(spacing: 10) {
            Circle().fill(Color.neonYellow).frame(width: 30, height: 30)
            Text("Neon Yellow").foregroundColor(.neonYellow)
        }

        HStack(spacing: 10) {
            Circle().fill(Color.neonOrange).frame(width: 30, height: 30)
            Text("Neon Orange").foregroundColor(.neonOrange)
        }

        HStack(spacing: 10) {
            Circle().fill(Color(hex: "FF6B6B")).frame(width: 30, height: 30)
            Text("Hex Color").foregroundColor(Color(hex: "FF6B6B"))
        }
    }
    .padding()
    .background(Color.black)
}
