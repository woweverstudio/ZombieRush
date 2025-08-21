import SwiftUI

// MARK: - Neon Button Styles
enum NeonButtonStyle {
    case cyan
    case magenta
    case white
    
    var color: Color {
        switch self {
        case .cyan:
            return Color(red: 0.0, green: 0.8, blue: 1.0)
        case .magenta:
            return Color(red: 1.0, green: 0.0, blue: 1.0)
        case .white:
            return Color.white
        }
    }
}

// MARK: - Neon Button Component
struct NeonButton: View {
    let title: String
    let style: NeonButtonStyle
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    init(
        _ title: String,
        style: NeonButtonStyle = .cyan,
        width: CGFloat = 240,
        height: CGFloat = 60,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.width = width
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            action()
        }) {
            Text(title)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundColor(style.color)
                .shadow(color: style.color, radius: 10, x: 0, y: 0)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style.color, lineWidth: 2)
                                .shadow(color: style.color, radius: 15, x: 0, y: 0)
                        )
                )
                .shadow(color: style.color.opacity(0.5), radius: 20, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var fontSize: CGFloat {
        // 버튼 크기에 따라 폰트 크기 조정
        if width < 150 {
            return 18
        } else if width < 200 {
            return 22
        } else {
            return 28
        }
    }
}

// MARK: - Icon Button Component
struct NeonIconButton: View {
    let icon: String
    let style: NeonButtonStyle
    let size: CGFloat
    let action: () -> Void
    
    init(
        icon: String,
        style: NeonButtonStyle = .magenta,
        size: CGFloat = 28,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(style.color)
                .shadow(color: style.color, radius: 8, x: 0, y: 0)
                .padding()
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(style.color, lineWidth: 2)
                        )
                )
                .shadow(color: style.color.opacity(0.4), radius: 15, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        NeonButton("GAME START") {}
        NeonButton("QUIT", style: .magenta, width: 140, height: 50) {}
        NeonIconButton(icon: "gearshape.fill") {}
    }
    .padding()
    .background(Color.black)
}
