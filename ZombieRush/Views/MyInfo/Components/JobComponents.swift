import SwiftUI

extension JobInfoCard {
    static let healthLabel = NSLocalizedString("체력", tableName: "MyInfo", comment: "Health label")
    static let energyLabel = NSLocalizedString("에너지", tableName: "MyInfo", comment: "Energy label")
    static let moveSpeedLabel = NSLocalizedString("이동속도", tableName: "MyInfo", comment: "Move speed label")
    static let attackSpeedLabel = NSLocalizedString("공격속도", tableName: "MyInfo", comment: "Attack speed label")
    static let unlockButton = NSLocalizedString("해금하기", tableName: "MyInfo", comment: "Unlock button")
    static let basicJobLabel = NSLocalizedString("기본 직업", tableName: "MyInfo", comment: "Basic job label")
}

// MARK: - Job Info Card
struct JobInfoCard: View {
    let jobType: JobType
    let isUnlocked: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Card(style: isSelected ? .selected : (isUnlocked ? .default : .disabled)) {
                VStack(spacing: 8) {
                    ZStack {
                        // 직업 아이콘
                        Image(systemName: jobType.iconName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isUnlocked ? .white : .gray.opacity(0.5))
                            .frame(width: 50, height: 50)

                        // 잠금 오버레이
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)
                            .background(
                                Circle()
                                    .fill(Color.dsOverlay)
                                    .frame(width: 24, height: 24)
                            )
                        }
                    }

                    // 직업 이름
                    Text(jobType.displayName)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(isUnlocked ? .white : .gray.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
//        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Job Detail Panel
struct JobDetailPanel: View {
    let jobType: JobType
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(GameKitManager.self) var gameKitManager

    var body: some View {
        VStack(spacing: 12) {
            // 상단: 직업 이름 + 아이콘
            HStack(spacing: 12) {
                Image(systemName: jobType.iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.cyan)
                    .frame(width: 24, height: 24)

                Text(jobType.displayName)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)

                Spacer()
            }

            // 중앙: 스텟 정보 (2줄로 압축)
            HStack(alignment: .center, spacing: 15) {
                let stats = JobStats.getStats(for: jobType.rawValue)

                // 좌측 그룹: 체력, 에너지
                VStack(alignment: .leading, spacing: 4) {
                    StatRow(icon: "heart.fill", label: JobInfoCard.healthLabel, value: "\(stats.hp)", color: .red)
                    StatRow(icon: "bolt.fill", label: JobInfoCard.energyLabel, value: "\(stats.energy)", color: .blue)
                }

                // 우측 그룹: 이동속도, 공격속도
                VStack(alignment: .leading, spacing: 4) {
                    StatRow(icon: "shoeprints.fill", label: JobInfoCard.moveSpeedLabel, value: "\(stats.move)", color: .green)
                    StatRow(icon: "bolt.horizontal.fill", label: JobInfoCard.attackSpeedLabel, value: "\(stats.attackSpeed)", color: .yellow)
                }
            }

            // 하단: 해금 정보 및 버튼
            if !(jobsRepository.currentJobs?.unlockedJobs.contains(jobType) ?? false) {
                let stats = JobStats.getStats(for: jobType.rawValue)

                if let requirement = stats.unlockRequirement {
                    // 해금 조건 표시 (간단하게 표시)
                    VStack(spacing: 6) {
                        Text("\(requirement.spiritType) 정령 \(requirement.count)개, Lv.\(requirement.requiredLevel) 필요")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .center)

                        PrimaryButton(
                            title: JobInfoCard.unlockButton,
                            style: .cyan,
                            fullWidth: true
                        ) {
                            Task {
                                let request = UnlockJobRequest(jobType: jobType)
                                let response = await useCaseFactory.unlockJob.execute(request)
                                
                                if response.success {
                                    let request = SelectJobRequest(jobType: jobType)
                                    let _ = await useCaseFactory.selectJob.execute(request)
                                }
                            }
                        }
                    }
                } else {
                    // 해금 조건 없는 경우 (novice 등)
                    Text(verbatim: JobInfoCard.basicJobLabel)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

}

