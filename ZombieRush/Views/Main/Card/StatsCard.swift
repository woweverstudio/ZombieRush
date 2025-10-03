import SwiftUI

extension StatsCard {
    static let remainingPointsFormat = NSLocalizedString("remaining_points", tableName: "Main", comment: "Remaining points format")
    static let hpLabel = NSLocalizedString("hp_label", tableName: "Main", comment: "HP stat label")
    static let moveSpeedLabel = NSLocalizedString("move_speed_label", tableName: "Main", comment: "Move speed stat label")
    static let energyStatLabel = NSLocalizedString("energy_stat_label", tableName: "Main", comment: "Energy stat label")
    static let attackSpeedLabel = NSLocalizedString("attack_speed_label", tableName: "Main", comment: "Attack speed stat label")
    
    // Shared keys used in PlayerInfoCard
    static let healthLabel = NSLocalizedString("health_label", tableName: "MyInfo", comment: "Health label")
    static let energyInfoLabel = NSLocalizedString("energy_label", tableName: "MyInfo", comment: "Energy label")
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
        guard let user = userRepository.currentUser, user.remainingPoints > 0 else {
            ToastManager.shared.show(.lackOfRemaingStatPoints)
            return
        }

        isUpgrading = true
        AudioManager.shared.playButtonSound()
        HapticManager.shared.playButtonHaptic()

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
                    Text(NSLocalizedString("ability_header", tableName: "Main", comment: "Ability header"))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 6)

                    Text(NSLocalizedString("increase_amount_header", tableName: "Main", comment: "Increase amount header"))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 60, alignment: .center)

                    Text(NSLocalizedString("final_header", tableName: "Main", comment: "Final header"))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 80, alignment: .center)

                    Text(NSLocalizedString("upgrade_header", tableName: "Main", comment: "Upgrade header"))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 80, alignment: .center)
                }
                .padding(8)

                ForEach(StatType.allCases, id: \.self) { statType in
                    if let jobs = jobsRepository.currentJobs, let currentStats = statsRepository.currentStats {
                        StatTableRow(
                            icon: statType.iconName,
                            label: statType.localizedDisplayName,
                            baseValue: JobStats.getStat(job: jobs.selectedJobType, stat: statType),
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
                ZStack{
                    CardBackground()
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.2))
                        .padding(1)
                }
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
                .offset(x: 8, y: -8)
            }
        }
    }
}

