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
                    // 해금 조건 표시 (한 줄로 압축)
                    let canUnlock = canUnlockJob(requirement: requirement)
                    let currentCount = getCurrentSpiritCount(for: requirement.spiritType)
                    let currentLevel = userStateManager.level?.currentLevel ?? 0

                    VStack(spacing: 6) {
                        // 조건을 한 줄에 모두 표시
                        HStack(spacing: 12) {
                            // 정령 정보
                            HStack(spacing: 4) {
                                Text(getSpiritDisplayName(for: requirement.spiritType))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(getSpiritColor(for: requirement.spiritType))

                                Text("\(currentCount)/\(requirement.count)")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(currentCount >= requirement.count ? .green : .red)
                            }

                            // 레벨 정보
                            HStack(spacing: 4) {
                                Text("Lv.\(currentLevel)/\(requirement.requiredLevel)")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(currentLevel >= requirement.requiredLevel ? .green : .red)
                            }

                            Spacer()
                        }

                        PrimaryButton(
                            title: "해금하기",
                            style: canUnlock ? .cyan : .disabled,
                            fullWidth: true
                        ) {
                            Task {
                                await unlockJob()
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

    private func unlockJob() async {
        let stats = JobStats.getStats(for: jobType.rawValue)

        guard let requirement = stats.unlockRequirement else {
            // 해금 조건이 없는 경우 (novice 등)
            await unlockJobDirectly()
            return
        }

        // 정령 개수 및 레벨 확인
        guard canUnlockJob(requirement: requirement) else {
            let currentCount = getCurrentSpiritCount(for: requirement.spiritType)
            let currentLevel = userStateManager.level?.currentLevel ?? 0

            if currentCount < requirement.count && currentLevel < requirement.requiredLevel {
                print("💎 직업 해금 실패: \(requirement.spiritType) 정령 \(requirement.count)개와 Lv.\(requirement.requiredLevel)이 필요합니다")
            } else if currentCount < requirement.count {
                print("💎 직업 해금 실패: \(requirement.spiritType) 정령이 \(requirement.count)개 필요합니다 (현재: \(currentCount)개)")
            } else if currentLevel < requirement.requiredLevel {
                print("💎 직업 해금 실패: Lv.\(requirement.requiredLevel)이 필요합니다 (현재: Lv.\(currentLevel))")
            }
            return
        }

        // 정령 개수 차감 및 해금
        await unlockJobWithSpirits(requirement: requirement)
    }

    private func canUnlockJob(requirement: JobUnlockRequirement) -> Bool {
        guard let spirits = spiritsStateManager.currentSpirits else {
            return false
        }

        // 정령 개수 확인
        let currentCount = getSpiritCount(for: requirement.spiritType, from: spirits)
        let hasEnoughSpirits = currentCount >= requirement.count

        // 레벨 확인
        let currentLevel = userStateManager.level?.currentLevel ?? 0
        let hasRequiredLevel = currentLevel >= requirement.requiredLevel

        return hasEnoughSpirits && hasRequiredLevel
    }

    private func getSpiritCount(for spiritType: String, from spirits: Spirits) -> Int {
        switch spiritType {
        case "fire": return spirits.fire
        case "ice": return spirits.ice
        case "lightning": return spirits.lightning
        case "dark": return spirits.dark
        default: return 0
        }
    }

    private func unlockJobWithSpirits(requirement: JobUnlockRequirement) async {
        // 정령 개수 차감
        await consumeSpirits(for: requirement.spiritType, count: requirement.count)
        // 직업 해금
        await unlockJobDirectly()
        print("🔥 직업 \(jobType.displayName) 해금 완료! \(requirement.spiritType) 정령 \(requirement.count)개 소비")
    }

    private func consumeSpirits(for spiritType: String, count: Int) async {
        switch spiritType {
        case "fire":
            await spiritsStateManager.addSpirit(.fire, count: -count)
        case "ice":
            await spiritsStateManager.addSpirit(.ice, count: -count)
        case "lightning":
            await spiritsStateManager.addSpirit(.lightning, count: -count)
        case "dark":
            await spiritsStateManager.addSpirit(.dark, count: -count)
        default:
            break
        }
    }

    private func unlockJobDirectly() async {
        // 직업 해금 로직
        await jobsStateManager.unlockJob(jobType)
        print("🔓 직업 \(jobType.displayName) 해금됨")
    }

    private func getSpiritDisplayName(for spiritType: String) -> String {
        switch spiritType {
        case "fire": return "불 정령"
        case "ice": return "얼음 정령"
        case "lightning": return "번개 정령"
        case "dark": return "어둠 정령"
        default: return "알 수 없는 정령"
        }
    }

    private func getSpiritColor(for spiritType: String) -> Color {
        switch spiritType {
        case "fire": return .red
        case "ice": return .blue
        case "lightning": return .yellow
        case "dark": return .purple
        default: return .gray
        }
    }

    private func getCurrentSpiritCount(for spiritType: String) -> Int {
        guard let spirits = spiritsStateManager.currentSpirits else {
            return 0
        }

        return getSpiritCount(for: spiritType, from: spirits)
    }
}

