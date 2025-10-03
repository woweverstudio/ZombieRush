import SwiftUI

// MARK: - Icon Button Style
enum IconButtonStyle {
    case cyan
    case magenta
    case white
    case yellow
    case orange
    case gray

    var color: Color {
        switch self {
        case .cyan:
            return Color(red: 0.0, green: 0.8, blue: 1.0)
        case .magenta:
            return Color(red: 1.0, green: 0.0, blue: 1.0)
        case .white:
            return Color.white
        case .yellow:
            return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .orange:
            return Color(red: 0.5, green: 1.0, blue: 0.3)
        case .gray:
            return Color.gray
        }
    }
}

// MARK: - Icon Button Component
struct IconButton: View {
    let iconName: String
    let style: IconButtonStyle
    let size: CGFloat
    let action: () -> Void

    init(
        iconName: String,
        style: IconButtonStyle = .cyan,
        size: CGFloat = 24,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()

            // 즉시 액션 실행 (UI 반응성 최우선)
            action()
        }) {
            Image(systemName: iconName)
                .font(.system(size: size))
                .foregroundColor(style.color)
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(style.color, lineWidth: 2)
                        )
                )
                .shadow(color: style.color.opacity(0.4), radius: 4, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Icon Button Component
struct IconRectButton: View {
    let iconName: String
    let description: String
    let style: IconButtonStyle
    let size: CGFloat
    let action: () -> Void

    init(
        iconName: String,
        description: String = "",
        style: IconButtonStyle = .cyan,
        size: CGFloat = 24,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.description = description
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()

            // 즉시 액션 실행 (UI 반응성 최우선)
            action()
        }) {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: size))
                    .frame(width: size * 1.5, height: size * 1.5)
                    .foregroundColor(style.color.opacity(0.9))
                
                Text(description)
                    .font(.system(size: size * 0.5, weight: .medium, design: .monospaced))
                    .foregroundColor(style.color.opacity(0.9))
                    .minimumScaleFactor(0.8)
            }
            .padding(size * 0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style.color.opacity(0.5), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            IconButton(iconName: "chevron.left", style: .white) {
                print("Back tapped")
            }

            IconButton(iconName: "gearshape.fill", style: .cyan) {
                print("Settings tapped")
            }

            IconButton(iconName: "xmark", style: .magenta) {
                print("Close tapped")
            }
        }

        IconButton(iconName: "play.fill", style: .yellow, size: 40) {
            print("Play tapped")
        }
        
        IconRectButton(iconName: "play.fill", style: .yellow, size: 40) {
            print("Play tapped")
        }
    }
    .padding()
    .background(Color.black)
}
