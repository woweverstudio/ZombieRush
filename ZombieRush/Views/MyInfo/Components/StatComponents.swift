import SwiftUI
import Foundation  // StatType을 위해 추가

extension StatInfoCard {
    static let descriptionLabel = NSLocalizedString("description_label", tableName: "MyInfo", comment: "Description label")
    static let upgradeButton = NSLocalizedString("upgrade_button", tableName: "MyInfo", comment: "Upgrade button")
}

// MARK: - Stat Info Card
struct StatInfoCard: View {
    let statType: StatType
    let isSelected: Bool
    let currentValue: Int
    let onTap: () -> Void

    var body: some View {
        SelectionInfoCard(
            title: statType.localizedDisplayName,
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

                Text(verbatim: statType.localizedDisplayName)
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
                Text(verbatim: StatInfoCard.descriptionLabel)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)

                Text(verbatim: statType.localizedDescription)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }

            Spacer()

            // 업그레이드 버튼
            PrimaryButton(
                title: StatInfoCard.upgradeButton,
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
//        let request = ConsumeStatPointsRequest(pointsToConsume: 1)
//        let response = await useCaseFactory.consumeStatPoints.execute(request)
//        
//        if response.success {
//            let request = UpgradeStatRequest(statType: statType)
//            _ = await useCaseFactory.upgradeStat.execute(request)
//        }
    }

    private func getCurrentStatValue() -> Int {
        guard let stats = statsRepository.currentStats else { return 0 }

        return stats[statType]
    }

}
