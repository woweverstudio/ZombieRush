import SwiftUI

// MARK: - Spirit Info Card
struct SpiritInfoCard: View {
    let spiritType: SpiritType
    let isSelected: Bool
    let currentCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 정령 아이콘
                Image(systemName: spiritType.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(spiritType.color)
                    .frame(width: 50, height: 50)

                // 정령 이름
                Text(spiritType.displayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 현재 개수
                Text("\(currentCount)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Spirit Detail Panel
struct SpiritDetailPanel: View {
    let spiritType: SpiritType
    @Environment(SpiritsStateManager.self) var spiritsStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: spiritType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(spiritType.color)

                Text(spiritType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // 현재 개수 표시
                Text("\(getCurrentSpiritCount())마리")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // 설명
            VStack(alignment: .leading, spacing: 12) {
                Text("능력")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)

                Text(spiritType.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }

            Spacer()

            // 정령 현황
            VStack(alignment: .leading, spacing: 8) {
                Text("보유 현황")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)

                HStack {
                    Text("현재:")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))

                    Text("\(getCurrentSpiritCount())마리")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(spiritType.color)
                }
            }
        }
        .padding(20)
    }

    private func getCurrentSpiritCount() -> Int {
        guard let spirits = spiritsStateManager.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }
}
