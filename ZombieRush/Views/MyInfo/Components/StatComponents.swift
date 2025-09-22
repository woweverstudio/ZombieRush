import SwiftUI

// MARK: - Stat Info Card
struct StatInfoCard: View {
    let statType: StatType
    let isSelected: Bool
    let currentValue: Int
    let onTap: () -> Void

    var body: some View {
        SelectionInfoCard(
            title: statType.displayName,
            iconName: statType.iconName,
            iconColor: statType.color,
            value: "\(currentValue)",
            isSelected: isSelected,
            action: onTap
        )
    }
}

// MARK: - Stat Detail Panel
struct StatDetailPanel: View {
    let statType: StatType
    @Environment(StatsStateManager.self) var statsStateManager
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: statType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(statType.color)

                Text(statType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)

                Spacer()

                // 현재 값 표시
                Text("\(getCurrentStatValue())")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)
            }

            Divider()
                .background(Color.dsTextSecondary.opacity(0.3))

            // 설명
            VStack(alignment: .leading, spacing: 12) {
                Text("설명")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)

                Text(statType.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }

            Spacer()

            // 업그레이드 버튼
            PrimaryButton(
                title: "업그레이드",
                style: userStateManager.remainingPoints >= 1 ? .cyan : .disabled,
                trailingContent: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("1")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(userStateManager.remainingPoints >= 1 ? .yellow : .gray.opacity(0.5))
                },
                action: {
                    Task {
                        await upgradeStat()
                    }
                }
            )
        }
        .padding(20)
    }

    private func getCurrentStatValue() -> Int {
        guard let stats = statsStateManager.currentStats else { return 0 }

        switch statType {
        case .hpRecovery: return stats.hpRecovery
        case .moveSpeed: return stats.moveSpeed
        case .energyRecovery: return stats.energyRecovery
        case .attackSpeed: return stats.attackSpeed
        case .totemCount: return stats.totemCount
        }
    }

    private func upgradeStat() async {
        // 포인트 차감 (포인트 확인 및 차감은 메소드 내부에서 처리)
        let success = await userStateManager.consumeRemainingPoints(1)

        if success {
            // 스텟 업그레이드
            await statsStateManager.upgradeStat(statType)

            // UI 업데이트 강제
            await MainActor.run {
                print("🔄 스텟 업그레이드 완료 - 포인트: \(userStateManager.remainingPoints)")
            }
        } else {
            print("❌ 포인트가 부족합니다")
        }
    }
}
