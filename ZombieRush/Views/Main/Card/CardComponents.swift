import SwiftUI

// MARK: - Card Background Component
struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.dsCard)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
                    .frame(maxHeight: .infinity)
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

// MARK: - Stat Row Component
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    init(icon: String, label: String, value: String, color: Color) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))
                .frame(width: 20, alignment: .leading)

            Text("\(label):")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 50, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Mini Stat Card Component
struct StatMiniCard: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            // 아이콘
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(color)
                

            // 라벨
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color.dsTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            // 값
            Text("\(value)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.dsCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}
