import SwiftUI

// MARK: - Secondary Button Style
enum SecondaryButtonStyle {
    case `default`
    case selected
    case disabled

    var backgroundColor: Color {
        switch self {
        case .default:
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
        }
    }

    var textColor: Color {
        switch self {
        case .selected:
            return .white
        case .disabled:
            return Color.gray.opacity(0.5)
        default:
            return .gray
        }
    }
}

// MARK: - Secondary Button Component (Smaller, for quantity selection etc.)
struct SecondaryButton: View {
    let title: String
    let style: SecondaryButtonStyle
    let action: () -> Void

    init(
        title: String,
        style: SecondaryButtonStyle = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(style.textColor)
                .frame(width: 50, height: 32)
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
