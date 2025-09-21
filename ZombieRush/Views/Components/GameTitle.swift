import SwiftUI

// MARK: - Game Title Component
struct GameTitle: View {
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    
    init(titleSize: CGFloat = 32, subtitleSize: CGFloat = 48) {
        self.titleSize = titleSize
        self.subtitleSize = subtitleSize
    }
    
    var body: some View {
        VStack(spacing: max(titleSize * 0.2, 8)) {
            Text(TextConstants.GameStart.titleLine1)
                .font(.system(size: titleSize, weight: .heavy, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 1.0))
                .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0), radius: 15, x: 0, y: 0)
                .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.5), radius: 30, x: 0, y: 0)

            Text(TextConstants.GameStart.titleLine2)
                .font(.system(size: subtitleSize, weight: .heavy, design: .monospaced))
                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 20, x: 0, y: 0)
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.5), radius: 40, x: 0, y: 0)
        }
    }
}

// MARK: - Section Title Component
struct SectionTitle: View {
    let title: String
    let style: NeonButtonStyle
    let size: CGFloat
    
    init(_ title: String, style: NeonButtonStyle = .cyan, size: CGFloat = 24) {
        self.title = title
        self.style = style
        self.size = size
    }
    
    var body: some View {
        Text(title)
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundColor(style.color)
            .shadow(color: style.color, radius: 10, x: 0, y: 0)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        GameTitle()
        SectionTitle("SETTINGS")
        SectionTitle("GAME OVER", style: .magenta, size: 32)
    }
    .padding()
    .background(Color.dsBackground)
}
