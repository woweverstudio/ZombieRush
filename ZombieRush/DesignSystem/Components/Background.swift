import SwiftUI

// MARK: - Background Component
struct Background: View {
    var body: some View {
        // 선형 그라데이션 배경 (위에서 아래로)
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#0f0c29"),   // 어두운 청록색
                Color(hex: "#302b63"),   // 중간 청록색
                Color(hex: "#2C5364")    // 밝은 청록색
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    Background()
}
