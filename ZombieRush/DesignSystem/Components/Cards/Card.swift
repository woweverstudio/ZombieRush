import SwiftUI

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func conditionalModifier<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Card Styles
enum CardStyle {
    case `default`
    case selected
    case disabled
    case cyberpunk
    case locked
    case error

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
        case .locked:
            return Color.black.opacity(0.3) // cyberpunk와 같은 배경
        case .error:
            return Color.red.opacity(0.1)
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
        case .locked:
            return Color.white.opacity(0.1) // cyberpunk와 같은 테두리
        case .error:
            return Color.red.opacity(0.5)
        }
    }

    var borderWidth: CGFloat {
        return 1
    }

    var cornerRadius: CGFloat {
        switch self {
        case .cyberpunk:
            return 12
        case .locked:
            return 12 // cyberpunk와 같은 corner radius
        default:
            return 8
        }
    }
}

// MARK: - Card Configuration
struct CardConfiguration {
    var style: CardStyle
    var customBackgroundColor: Color? = nil
    var customBorderColor: Color? = nil
    var customBorderWidth: CGFloat? = nil
    var customCornerRadius: CGFloat? = nil
    var shadowEnabled: Bool = false
    var shadowColor: Color = .black
    var shadowRadius: CGFloat = 4
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 2
    var contentPadding: EdgeInsets = EdgeInsets(top: UIConstants.Spacing.x12, leading: UIConstants.Spacing.x16, bottom: UIConstants.Spacing.x12, trailing: UIConstants.Spacing.x16)
    var maxWidth: CGFloat? = nil

    // Computed properties
    var backgroundColor: Color {
        customBackgroundColor ?? style.backgroundColor
    }

    var borderColor: Color {
        customBorderColor ?? style.borderColor
    }

    var borderWidth: CGFloat {
        customBorderWidth ?? style.borderWidth
    }

    var cornerRadius: CGFloat {
        customCornerRadius ?? style.cornerRadius
    }
}

// MARK: - Base Card Component
struct Card<Content: View>: View {
    let configuration: CardConfiguration
    let content: Content

    init(
        style: CardStyle = .default,
        customBackgroundColor: Color? = nil,
        customBorderColor: Color? = nil,
        customBorderWidth: CGFloat? = nil,
        customCornerRadius: CGFloat? = nil,
        shadowEnabled: Bool = false,
        shadowColor: Color = .black,
        shadowRadius: CGFloat = 4,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 2,
        contentPadding: EdgeInsets = EdgeInsets(top: UIConstants.Spacing.x12, leading: UIConstants.Spacing.x16, bottom: UIConstants.Spacing.x12, trailing: UIConstants.Spacing.x16),
        maxWidth: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = CardConfiguration(
            style: style,
            customBackgroundColor: customBackgroundColor,
            customBorderColor: customBorderColor,
            customBorderWidth: customBorderWidth,
            customCornerRadius: customCornerRadius,
            shadowEnabled: shadowEnabled,
            shadowColor: shadowColor,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY,
            contentPadding: contentPadding,
            maxWidth: maxWidth
        )
        self.content = content()
    }


    var body: some View {
        ZStack {
            content
                .frame(maxWidth: configuration.maxWidth)
                .padding(configuration.contentPadding)
                .background(
                    RoundedRectangle(cornerRadius: configuration.cornerRadius)
                        .fill(configuration.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                                .stroke(configuration.borderColor, lineWidth: configuration.borderWidth)
                        )
                        .conditionalModifier(configuration.shadowEnabled) { view in
                            view.shadow(
                                color: configuration.shadowColor.opacity(0.3),
                                radius: configuration.shadowRadius,
                                x: configuration.shadowX,
                                y: configuration.shadowY
                            )
                        }
                )

            // Locked 스타일일 때 자물쇠 오버레이 추가
            if configuration.style == .locked {
                Color.black.opacity(0.7)
                    .cornerRadius(configuration.cornerRadius)
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Convenience Initializers
extension Card {
    init(configuration: CardConfiguration, @ViewBuilder content: () -> Content) {
        self.configuration = configuration
        self.content = content()
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

        Card(style: .locked) {
            Text("Locked Card")
                .foregroundColor(.white)
        }
    }
    .padding()
    .background(Color.black)
}
