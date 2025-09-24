import SwiftUI
import Foundation  // StatType을 위해 추가

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
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var statsRepository: SupabaseStatsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(GameKitManager.self) var gameKitManager

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

//                Text(statType.description)
//                    .font(.system(size: 14, design: .monospaced))
//                    .foregroundColor(.white.opacity(0.8))
//                    .lineSpacing(4)
            }

            Spacer()

            // 업그레이드 버튼
            PrimaryButton(
                title: "업그레이드",
                style: canAffordUpgrade() ? .cyan : .disabled,
                trailingContent: {
                    StatsPointCost(count: 1)
                        .foregroundColor(canAffordUpgrade() ? Color.dsCoin : .gray.opacity(0.5))
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

    private func canAffordUpgrade() -> Bool {
        let remainingPoints = userRepository.currentUser?.remainingPoints ?? 0
        return remainingPoints >= 1
    }

    private func upgradeStat() async {
        let request = UpgradeStatRequest(statType: statType)
        _ = try? await useCaseFactory.upgradeStat.execute(request)
    }

    private func getCurrentStatValue() -> Int {
        guard let stats = statsRepository.currentStats else { return 0 }

        switch statType {
        case .hpRecovery: return stats.hpRecovery
        case .moveSpeed: return stats.moveSpeed
        case .energyRecovery: return stats.energyRecovery
        case .attackSpeed: return stats.attackSpeed
        case .totemCount: return stats.totemCount
        }
    }

}
