import SwiftUI

enum CustomBackGroundStyle {
    case linearGradient
    case image(String)
}

// MARK: - Background Component
struct Background: View {
    let style: CustomBackGroundStyle
    
    init(style: CustomBackGroundStyle = .linearGradient) {
        self.style = style
    }
    
    var body: some View {
        // 선형 그라데이션 배경 (위에서 아래로)
        Group {
            switch style {
            case .linearGradient:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0f0c29"),   // 어두운 청록색
                        Color(hex: "#302b63"),   // 중간 청록색
                        Color(hex: "#2C5364")    // 밝은 청록색
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .image(let imageName):
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    Background()
}
