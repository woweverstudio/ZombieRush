import SwiftUI

// MARK: - Cyberpunk Background Component
struct CyberpunkBackground: View {
    let opacity: Double
    
    init(opacity: Double = 0.3) {
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            // 다양한 색상의 다크 그라데이션 배경
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.0, blue: 0.15),  // 어두운 파란색
                    Color(red: 0.12, green: 0.02, blue: 0.08), // 어두운 보라색
                    Color(red: 0.0, green: 0.05, blue: 0.1),   // 어두운 청록색
                    Color(red: 0.08, green: 0.0, blue: 0.08),  // 어두운 녹색
                    Color(red: 0.0, green: 0.0, blue: 0.0)     // 블랙
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 800
            )

            // 미세한 밝기 조절을 위한 얇은 오버레이
            Color.black.opacity(opacity)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    CyberpunkBackground()
}
