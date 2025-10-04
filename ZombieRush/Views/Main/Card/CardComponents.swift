import SwiftUI

// MARK: - Card Background Component
struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.dsCard)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    .blur(radius: 0.5)
                    .frame(maxHeight: .infinity)
            )
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
                .frame(width: 60, alignment: .leading)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Stat Table Row Component (테이블용)
struct StatTableRow: View {
    let icon: String
    let label: String
    let baseValue: Int
    let upgradeValue: Int
    let color: Color
    let canUpgrade: Bool
    let action: () async -> Void

    private var finalValue: Int { baseValue + upgradeValue }

    var body: some View {
        HStack(spacing: 0) {
            // 스탯 이름 (아이콘 + 라벨)
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12))

                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 6)

            // 증가량
            Text(upgradeValue > 0 ? "+\(upgradeValue)" : "-")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(upgradeValue > 0 ? color.opacity(0.9) : .white.opacity(0.4))
                .frame(width: 60, alignment: .center)

            // 최종 스텟
            Text("\(finalValue)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
                .frame(width: 80, alignment: .center)

            // 업그레이드 버튼
            Button(action: {
                Task { await action() }
            }) {
                Image(systemName: "arrow.up")
                    .foregroundColor(canUpgrade ? color.opacity(0.6) : Color.gray.opacity(0.3))
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 80, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(canUpgrade ? color.opacity(0.1) : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(canUpgrade ? color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                    )
            }
            .frame(width: 80)
            .disabled(!canUpgrade)
        }
        .padding(8)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.02))
        )
    }
}
