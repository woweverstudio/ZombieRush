import SwiftUI

// MARK: - Back Button Component
struct BackButton: View {
    let action: () -> Void
    let style: NeonButtonStyle
    
    init(style: NeonButtonStyle = .cyan, action: @escaping () -> Void) {
        self.style = style
        self.action = action
    }
    
    var body: some View {
        NeonIconButton(
            icon: "chevron.left",
            style: style,
            size: 22  // 기본 28에서 22로 축소
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
    .background(Color.black)
}
