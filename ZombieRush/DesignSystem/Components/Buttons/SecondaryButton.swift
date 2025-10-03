import SwiftUI

// MARK: - Secondary Button Style
enum SecondaryButtonStyle {
    case `default`
    case selected
    case disabled
    case accent

    var backgroundColor: Color {
        switch self {
        case .default, .accent:
            return Color.gray.opacity(0.2)
        case .selected:
            return Color.cyan.opacity(0.3)
        case .disabled:
            return Color.gray.opacity(0.1)
            
        }
    }

    var borderColor: Color {
        switch self {
        case .default:
            return Color.gray.opacity(0.5)
        case .selected:
            return Color.cyan
        case .disabled:
            return Color.gray.opacity(0.3)
        case .accent:
            return Color.white
        }
    }

    var textColor: Color {
        switch self {
        case .selected:
            return .white
        case .disabled:
            return Color.gray.opacity(0.5)
        case .default:
            return .gray
        case .accent:
            return .white        
        }
    }
}

// MARK: - Secondary Button Component (Smaller, for quantity selection etc.)
struct SecondaryButton: View {
    let title: String
    let style: SecondaryButtonStyle
    let fontSize: CGFloat
    let size: CGSize
    let action: () -> Void

    init(
        title: String,
        style: SecondaryButtonStyle = .default,
        fontSize: CGFloat = 12,
        size: CGSize = .init(width: 50, height: 32),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.fontSize = fontSize
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundColor(style.textColor)
                .frame(width: size.width, height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(style.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(style.borderColor, lineWidth: 1)
                        )
                )
        }
        .disabled(style == .disabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            SecondaryButton(title: "1", style: .default) {
                print("1 selected")
            }

            SecondaryButton(title: "5", style: .selected) {
                print("5 selected")
            }

            SecondaryButton(title: "10", style: .default) {
                print("10 selected")
            }
        }

        SecondaryButton(title: "MAX", style: .disabled) {
            print("Max selected")
        }
    }
    .padding()
    .background(Color.black)
}
