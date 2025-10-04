import SwiftUI

// MARK: - Requirement Card Component
struct RequirementCard: View {
    let title: String
    let value: String
    let currentValue: Int
    let isMet: Bool
    let iconName: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            // 아이콘과 체크마크
            ZStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)

                if isMet {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }

            Text(title)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 2) {
                Text("\(currentValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isMet ? .green : .white)

                Text("/")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))

                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isMet ? .green : .cyan)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isMet ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isMet ? Color.green.opacity(0.3) : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
