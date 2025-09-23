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
                    StatsPointCost(count: 1)
                        .foregroundColor(userStateManager.remainingPoints >= 1 ? Color.dsCoin : .gray.opacity(0.5))
                },
                action: {
                    Task {
                        let success = await statsStateManager.upgradeStatWithPoints(statType)
                        // ✅ refresh는 콜백을 통해 자동으로 수행됨
                        if success {
                            print("📊 스텟 업그레이드 완료")
                        }
                    }
                }
            )
        }
        .padding(20)
    }

}
