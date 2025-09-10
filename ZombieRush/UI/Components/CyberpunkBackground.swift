import SwiftUI

// MARK: - Cyberpunk Background Component
struct CyberpunkBackground: View {
    var body: some View {
        // 적당한 밝기의 그라데이션 배경 (연보라색 중앙)
        RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 0.08, green: 0.02, blue: 0.15),   // 적당한 파란색
                Color(red: 0.12, green: 0.04, blue: 0.12),   // 적당한 연보라색 (중앙)
                Color(red: 0.02, green: 0.0, blue: 0.05)     // 적당한 블랙
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 700
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    CyberpunkBackground()
}
