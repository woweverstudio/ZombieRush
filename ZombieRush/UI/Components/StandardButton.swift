import SwiftUI

// MARK: - Standard Button Color Types
enum StandardButtonColor {
    case main     // Cyan color for primary actions
    case warning  // Red color for destructive actions

    var color: Color {
        switch self {
        case .main:
            return Color(red: 0.0, green: 0.8, blue: 1.0) // Cyan
        case .warning:
            return Color.red
        }
    }
}

// MARK: - Standard Button Component
struct StandardButton: View {
    let title: String
    let width: CGFloat?
    let height: CGFloat
    let color: StandardButtonColor
    let action: () -> Void

    init(
        _ title: String,
        width: CGFloat? = nil,
        height: CGFloat = 50,
        color: StandardButtonColor = .main,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.color = color
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
                .frame(width: width, height: height)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.color)
                        .shadow(color: color.color.opacity(0.4), radius: 6, x: 0, y: 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        StandardButton("RESUME", width: 200, color: .main) {}
        StandardButton("SETTINGS", width: 150, height: 40, color: .main) {}
        StandardButton("QUIT", width: 180, color: .warning) {}
    }
    .padding()
    .background(Color.black)
}
