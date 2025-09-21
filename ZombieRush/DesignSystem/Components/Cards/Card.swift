import SwiftUI

// MARK: - Card Styles
enum CardStyle {
    case `default`
    case selected
    case disabled
    case cyberpunk

    var backgroundColor: Color {
        switch self {
        case .default:
            return Color.white.opacity(0.05)
        case .selected:
            return Color.cyan.opacity(0.2)
        case .disabled:
            return Color.gray.opacity(0.1)
        case .cyberpunk:
            return Color.black.opacity(0.3)
        }
    }

    var borderColor: Color {
        switch self {
        case .default:
            return Color.white.opacity(0.2)
        case .selected:
            return Color.cyan
        case .disabled:
            return Color.gray.opacity(0.3)
        case .cyberpunk:
            return Color.white.opacity(0.1)
        }
    }

    var borderWidth: CGFloat {
        return 1
    }

    var cornerRadius: CGFloat {
        switch self {
        case .cyberpunk:
            return 12
        default:
            return 8
        }
    }
}

// MARK: - Base Card Component
struct Card<Content: View>: View {
    let style: CardStyle
    let content: Content

    init(style: CardStyle = .default, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
    }
}

// MARK: - Convenience Initializers
extension Card {
    init(style: CardStyle = .default, content: Content) {
        self.style = style
        self.content = content
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        Card(style: .default) {
            Text("Default Card")
                .foregroundColor(.white)
        }

        Card(style: .selected) {
            Text("Selected Card")
                .foregroundColor(.white)
        }

        Card(style: .disabled) {
            Text("Disabled Card")
                .foregroundColor(.gray)
        }

        Card(style: .cyberpunk) {
            Text("Cyberpunk Card")
                .foregroundColor(.white)
        }
    }
    .padding()
    .background(Color.black)
}
