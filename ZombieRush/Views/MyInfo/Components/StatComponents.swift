import SwiftUI

// MARK: - Stat Info Card
struct StatInfoCard: View {
    let statType: StatType
    let isSelected: Bool
    let currentValue: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 스텟 아이콘
                Image(systemName: statType.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(statType.color)
                    .frame(width: 50, height: 50)

                // 스텟 이름
                Text(statType.displayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 현재 값
                Text("\(currentValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)
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
                    .foregroundColor(.white)

                Spacer()

                // 현재 값 표시
                Text("\(getCurrentStatValue())")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)
            }

            Divider()
                .background(Color.white.opacity(0.3))

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
            Button(action: {
                // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
                DispatchQueue.global(qos: .userInteractive).async {
                    AudioManager.shared.playButtonSound()
                    HapticManager.shared.playButtonHaptic()
                }
                
                Task {
                    await upgradeStat()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(userStateManager.remainingPoints >= 1 ? statType.color : .gray.opacity(0.5))

                    Text("업그레이드")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(userStateManager.remainingPoints >= 1 ? .white : .gray.opacity(0.5))

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(userStateManager.remainingPoints >= 1 ? .yellow : .gray.opacity(0.5))

                        Text("1")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(userStateManager.remainingPoints >= 1 ? .yellow : .gray.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(userStateManager.remainingPoints >= 1 ?
                              statType.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(userStateManager.remainingPoints >= 1 ?
                                        statType.color.opacity(0.5) : Color.gray.opacity(0.3),
                                        lineWidth: 1)
                        )
                )
            }
            .disabled(userStateManager.remainingPoints < 1)
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
