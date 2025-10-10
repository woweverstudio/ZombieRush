import SwiftUI

// MARK: - Primary Button Style
enum PrimaryButtonStyle {
    case cyan
    case magenta
    case white
    case yellow
    case orange
    case red
    case disabled

    var backgroundColor: Color {
        switch self {
        case .cyan:
            return Color.cyan.opacity(0.2)
        case .magenta:
            return Color.magenta.opacity(0.2)
        case .white:
            return Color.white.opacity(0.1)
        case .yellow:
            return Color.yellow.opacity(0.2)
        case .orange:
            return Color.orange.opacity(0.2)
        case .red:
            return Color.red.opacity(0.2)
        case .disabled:
            return Color.gray.opacity(0.1)
        }
    }

    var borderColor: Color {
        switch self {
        case .cyan:
            return Color.cyan.opacity(0.5)
        case .magenta:
            return Color.magenta.opacity(0.5)
        case .white:
            return Color.white.opacity(0.3)
        case .yellow:
            return Color.yellow.opacity(0.5)
        case .orange:
            return Color.orange.opacity(0.5)
        case .red:
            return Color.red.opacity(0.5)
        case .disabled:
            return Color.gray.opacity(0.3)
        }
    }

    var textColor: Color {
        switch self {
        case .disabled:
            return Color.gray.opacity(0.5)
        default:
            return .white
        }
    }

    var shadowColor: Color {
        switch self {
        case .cyan:
            return Color.cyan
        case .magenta:
            return Color.magenta
        case .white:
            return Color.white
        case .yellow:
            return Color.yellow
        case .orange:
            return Color.orange
        case .red:
            return Color.red
        case .disabled:
            return Color.clear
        }
    }
}

// MARK: - Primary Button Size
enum PrimaryButtonSize {
    case small
    case medium

    var fontSize: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return UIConstants.Spacing.x16
        case .medium:
            return UIConstants.Spacing.x24
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return UIConstants.Spacing.x8
        case .medium:
            return UIConstants.Spacing.x12
        }
    }
}

// MARK: - Primary Button Component
struct PrimaryButton<TrailingContent: View>: View {
    let title: String
    let style: PrimaryButtonStyle
    let size: PrimaryButtonSize
    let fullWidth: Bool
    let width: CGFloat?
    let height: CGFloat?
    let trailingContent: TrailingContent?
    let action: () -> Void

    init(
        title: String,
        style: PrimaryButtonStyle = .cyan,
        size: PrimaryButtonSize = .medium,
        fullWidth: Bool = false,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        action: @escaping () -> Void
    ) where TrailingContent == EmptyView {
        self.title = title
        self.style = style
        self.size = size
        self.fullWidth = fullWidth
        self.width = width
        self.height = height
        self.trailingContent = nil
        self.action = action
    }

    init(
        title: String,
        style: PrimaryButtonStyle = .cyan,
        size: PrimaryButtonSize = .medium,
        fullWidth: Bool = true,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.fullWidth = fullWidth
        self.width = width
        self.height = height
        self.trailingContent = trailingContent()
        self.action = action
    }

    var body: some View {
        Button(action: {
            // UI 피드백은 백그라운드에서 처리하여 응답성 향상
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            action()
        }) {
            Group {
                if let trailingContent = trailingContent {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: size.fontSize, weight: .bold, design: .monospaced))
                            .foregroundColor(style.textColor)

                        Spacer()
                        trailingContent
                    }
                } else {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(style.textColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(width: width, height: height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, height == nil ? size.verticalPadding : 0)
            .padding(.horizontal, width == nil ? size.horizontalPadding : 0)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style.borderColor, lineWidth: 1)
                    )
            )
            .shadow(color: style.shadowColor.opacity(0.3), radius: 4, x: 0, y: 0)
        }
        .disabled(style == .disabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // Full width buttons
        PrimaryButton(title: "구매하기", style: .cyan, fullWidth: true) {
            print("Purchase tapped")
        }

        PrimaryButton(title: "취소", style: .magenta, fullWidth: true) {
            print("Cancel tapped")
        }

        // Size variations
        HStack(spacing: 12) {
            PrimaryButton(title: "Small", style: .yellow, size: .small) {
                print("Small tapped")
            }

            PrimaryButton(title: "Medium", style: .orange) {
                print("Medium tapped")
            }
        }

        // Fixed size buttons (like StandardButton)
        HStack(spacing: 12) {
            PrimaryButton(title: "RESUME", style: .cyan, width: 120, height: 44) {
                print("Resume tapped")
            }

            PrimaryButton(title: "QUIT", style: .red, width: 100, height: 44) {
                print("Quit tapped")
            }
        }

        // Buttons with trailing content (like stat upgrade and element purchase)
        VStack(spacing: 12) {
            PrimaryButton(title: "업그레이드", style: .cyan, trailingContent: {
                StatsPointCost(count: 1)
            }, action: {
                print("Upgrade tapped")
            })

            PrimaryButton(title: "구매하기", style: .yellow, trailingContent: {
                HStack(spacing: 4) {
                    Image(systemName: "wonsign.circle.fill")
                        .font(.system(size: 12))
                    Text("₩1,000")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.green)
            }, action: {
                print("Purchase with cost tapped")
            })
        }

        PrimaryButton(title: "비활성화", style: .disabled, fullWidth: true) {
            print("Disabled tapped")
        }
    }
    .padding()
    .background(Color.black)
}
