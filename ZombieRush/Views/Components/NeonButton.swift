import SwiftUI

// MARK: - Neon Button Styles
enum NeonButtonStyle {
    case cyan
    case magenta
    case white
    case yellow
    case orange
    
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
        }
    }
}

enum NeonButtonSize {
    case small
    case medium
}

// MARK: - Neon Button Component
struct NeonButton: View {
    let title: String
    let style: NeonButtonStyle
    let fullWidth: Bool
    let size: NeonButtonSize
    let action: () -> Void
    
    init(
        _ title: String,
        style: NeonButtonStyle = .cyan,
        fullWidth: Bool = false,
        size: NeonButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.fullWidth = fullWidth
        self.size = size
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
            Text(title)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .font(.system(size: size == .medium ? 24 : 16, weight: .bold, design: .monospaced))
                .foregroundColor(style.color)
                .shadow(color: style.color, radius: 10, x: 0, y: 0)
                .padding(.horizontal, size == .medium ? 40 : 20)
                .padding(.vertical, size == .medium ? 16 : 10)
                .multilineTextAlignment(.center)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style.color, lineWidth: 2)
                                .shadow(color: style.color, radius: size == .medium ? 15 : 4, x: 0, y: 0)
                        )
                )
                .shadow(color: style.color.opacity(0.5), radius: size == .medium ? 20 : 5, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
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
            // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(style.color)                
                .padding()
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(style.color, lineWidth: 2)
                        )
                )
                .shadow(color: style.color.opacity(0.4), radius: 8, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        NeonButton("GAME START") {}
        NeonButton("QUIT", style: .magenta) {}
        NeonIconButton(icon: "gearshape.fill") {}
    }
    .padding()
    .background(Color.black)
}
