import SwiftUI

// MARK: - Primary Button Style
enum PrimaryButtonStyle {
    case cyan
    case magenta
    case white
    case yellow
    case orange
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
        case .disabled:
            return Color.clear
        }
    }
}

// MARK: - Primary Button Component
struct PrimaryButton: View {
    let title: String
    let style: PrimaryButtonStyle
    let fullWidth: Bool
    let action: () -> Void

    init(
        title: String,
        style: PrimaryButtonStyle = .cyan,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            action()
        }) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(style.textColor)

                Spacer()
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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
        PrimaryButton(title: "구매하기", style: .cyan, fullWidth: true) {
            print("Purchase tapped")
        }

        PrimaryButton(title: "취소", style: .magenta) {
            print("Cancel tapped")
        }

        PrimaryButton(title: "비활성화", style: .disabled, fullWidth: true) {
            print("Disabled tapped")
        }
    }
    .padding()
    .background(Color.black)
}
