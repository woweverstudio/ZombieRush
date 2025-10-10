import SwiftUI

extension StatsCard {
    static let remainingPointsFormat = NSLocalizedString("remaining_points", tableName: "View", comment: "Remaining points format")
    // Table headers
    static let abilityHeader = NSLocalizedString("ability_header", tableName: "View", comment: "Ability header")
    static let increaseAmountHeader = NSLocalizedString("increase_amount_header", tableName: "View", comment: "Increase amount header")
    static let finalHeader = NSLocalizedString("final_header", tableName: "View", comment: "Final header")
    static let upgradeHeader = NSLocalizedString("upgrade_header", tableName: "View", comment: "Upgrade header")
}

// MARK: - Stats Card
struct StatsCard: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var statsRepository: SupabaseStatsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    @State private var isUpgrading = false

    /// 스탯 업그레이드
    private func upgradeStat(_ statType: StatType) async {
        guard !isUpgrading else { return }

        isUpgrading = true

        let request = UpgradeStatRequest(statType: statType)
        let _ = await useCaseFactory.upgradeStat.execute(request)

        isUpgrading = false
    }
    
    /// 스텟 테이블
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // 테이블 헤더
                HStack(spacing: 0) {
                    Text(StatsCard.abilityHeader)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, UIConstants.Spacing.x4)

                    Text(StatsCard.increaseAmountHeader)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 60, alignment: .center)

                    Text(StatsCard.finalHeader)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 80, alignment: .center)

                    Text(StatsCard.upgradeHeader)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 80, alignment: .center)
                }
                .padding(UIConstants.Spacing.x8)

                ForEach(StatType.allCases, id: \.self) { statType in
                    if let currentStats = statsRepository.currentStats {
                        StatTableRow(
                            icon: statType.iconName,
                            label: statType.localizedDisplayName,
                            baseValue: JobStats.getStat(job: jobsRepository.selectedJobType, stat: statType),
                            upgradeValue: currentStats[statType],
                            color: statType.color,
                            canUpgrade: (userRepository.currentUser?.remainingPoints ?? 0) > 0 && !isUpgrading
                        ) {
                            await upgradeStat(statType)
                        }
                    }
                }

            }
            .background(
                CardBackground()
            )

            // 남은 스텟 포인트 배지
            if let remainingPoints = userRepository.currentUser?.remainingPoints, remainingPoints > 0 {
                ZStack {
                    Circle()
                        .fill(Color.dsError.opacity(0.9))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.dsTextPrimary.opacity(0.3), lineWidth: 1)
                        )

                    Text("\(remainingPoints)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.dsTextPrimary)
                }
                .offset(x: UIConstants.Spacing.x8, y: -UIConstants.Spacing.x8)
            }
        }
    }
}

