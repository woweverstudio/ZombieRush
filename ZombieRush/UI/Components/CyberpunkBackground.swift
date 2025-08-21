import SwiftUI

// MARK: - Cyberpunk Background Component
struct CyberpunkBackground: View {
    let opacity: Double
    
    init(opacity: Double = 0.3) {
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경 이미지
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 어두운 오버레이
            Color.black.opacity(opacity)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Preview
#Preview {
    CyberpunkBackground()
}
