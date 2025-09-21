import SwiftUI

// MARK: - Back Button Component
struct BackButton: View {
    let action: () -> Void
    let style: IconButtonStyle

    init(style: IconButtonStyle = .cyan, action: @escaping () -> Void) {
        self.style = style
        self.action = action
    }

    var body: some View {
        IconButton(
            iconName: "chevron.left",
            style: style,
            size: 22  // 기본 24에서 22로 축소
        ) {
            action()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        BackButton(style: .cyan) {}
        BackButton(style: .magenta) {}
    }
    .padding()
    .background(Color.dsBackground)
}
