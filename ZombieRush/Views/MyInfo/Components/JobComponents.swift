import SwiftUI

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
    @Environment(JobsStateManager.self) var jobsStateManager
    @Environment(UserStateManager.self) var userStateManager
    @Environment(SpiritsStateManager.self) var spiritsStateManager

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
                    StatRow(icon: "heart.fill", label: "체력", value: "\(stats.hp)", color: .red)
                    StatRow(icon: "bolt.fill", label: "에너지", value: "\(stats.energy)", color: .blue)
                }

                // 우측 그룹: 이동속도, 공격속도
                VStack(alignment: .leading, spacing: 4) {
                    StatRow(icon: "shoeprints.fill", label: "이동속도", value: "\(stats.move)", color: .green)
                    StatRow(icon: "bolt.horizontal.fill", label: "공격속도", value: "\(stats.attackSpeed)", color: .yellow)
                }
            }

            // 하단: 해금 정보 및 버튼
            if !jobsStateManager.currentJobs.unlockedJobs.contains(jobType) {
                let stats = JobStats.getStats(for: jobType.rawValue)

                if let requirement = stats.unlockRequirement {
                    // 해금 조건 표시 (간단하게 표시)
                    VStack(spacing: 6) {
                        Text("\(requirement.spiritType) 정령 \(requirement.count)개, Lv.\(requirement.requiredLevel) 필요")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .center)

                        PrimaryButton(
                            title: "해금하기",
                            style: .cyan,
                            fullWidth: true
                        ) {
                            Task {
                                await jobsStateManager.unlockJob(jobType)
                            }
                        }
                    }
                } else {
                    // 해금 조건 없는 경우 (novice 등)
                    Text("기본 직업")
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

