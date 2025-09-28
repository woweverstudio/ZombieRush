import SwiftUI

extension StatsCard {
    static let remainingPointsFormat = NSLocalizedString("remaining_points", tableName: "Main", comment: "Remaining points format")
    static let hpRecoveryLabel = NSLocalizedString("hp_recovery_label", tableName: "Main", comment: "HP recovery stat label")
    static let moveSpeedLabel = NSLocalizedString("move_speed_label", tableName: "Main", comment: "Move speed stat label")
    static let energyRecoveryLabel = NSLocalizedString("energy_recovery_label", tableName: "Main", comment: "Energy recovery stat label")
    static let attackSpeedLabel = NSLocalizedString("attack_speed_label", tableName: "Main", comment: "Attack speed stat label")
    static let totemLabel = NSLocalizedString("totem_label", tableName: "Main", comment: "Totem stat label")
}

// MARK: - Stats Card
struct StatsCard: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var statsRepository: SupabaseStatsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            
            router.navigate(to: .myInfo(category: .stats))
        }) {
            ZStack {
                CardBackground()
                
                VStack(spacing: 8) {
                    // 타이틀
                    // 남은 포인트 표시
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.dsCoin)
                            .font(.system(size: 10))

                        Text(verbatim: String(format: StatsCard.remainingPointsFormat, userRepository.currentUser?.remainingPoints ?? 0))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // 스텟 그리드 (3x2)
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        // 첫 번째 행 (3개)
                        StatMiniCard(
                            icon: "heart.fill",
                            label: StatsCard.hpRecoveryLabel,
                            value: statsRepository.currentStats?.hpRecovery ?? 0,
                            color: .red
                        )

                        StatMiniCard(
                            icon: "figure.run",
                            label: StatsCard.moveSpeedLabel,
                            value: statsRepository.currentStats?.moveSpeed ?? 0,
                            color: .green
                        )

                        StatMiniCard(
                            icon: "bolt.fill",
                            label: StatsCard.energyRecoveryLabel,
                            value: statsRepository.currentStats?.energyRecovery ?? 0,
                            color: .blue
                        )

                        // 두 번째 행 (2개)
                        StatMiniCard(
                            icon: "target",
                            label: StatsCard.attackSpeedLabel,
                            value: statsRepository.currentStats?.attackSpeed ?? 0,
                            color: .yellow
                        )

                        StatMiniCard(
                            icon: "building.columns",
                            label: StatsCard.totemLabel,
                            value: statsRepository.currentStats?.totemCount ?? 0,
                            color: .orange
                        )

                        // 네모의 응원 상태
                        CheerBuffCard(isActive: userRepository.currentUser?.isCheerBuffActive ?? false)
                    }
                }
                .padding()
            }
            .buttonStyle(.plain) // 버튼 스타일 제거
        }
    }
}

