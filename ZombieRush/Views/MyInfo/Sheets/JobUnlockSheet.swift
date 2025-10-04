import SwiftUI

// MARK: - Job Unlock Sheet
struct JobUnlockSheet: View {
    let jobType: JobType
    let currentLevel: Int
    let spiritCounts: [SpiritType: Int]
    let onUnlock: () -> Void

    // 임시 직업 설명
    private func getJobDescription(for jobType: JobType) -> String {
        switch jobType {
        case .novice:
            return "기본 직업입니다"
        case .fireMage:
            return "불 속성 마법을 사용합니다"
        case .iceMage:
            return "얼음 속성 마법을 사용합니다"
        case .thunderMage:
            return "번개 속성 마법을 사용합니다"
        case .darkMage:
            return "어둠 속성 마법을 사용합니다"
        }
    }

    // 직업 해금 가능 여부 확인
    private func canUnlockJob(_ jobType: JobType, currentLevel: Int, spiritCounts: [SpiritType: Int]) -> Bool {
        guard let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) else {
            return false
        }

        let levelMet = currentLevel >= requirement.requiredLevel

        if let spiritType = SpiritType(rawValue: requirement.requiredSpirit) {
            let spiritMet = spiritCounts[spiritType] ?? 0 >= requirement.requiredCount
            return levelMet && spiritMet
        }

        return levelMet
    }

    // 직업 스탯 정보 뷰
    private func jobStatsView() -> some View {
        let stats = JobStats.getStats(for: jobType.rawValue)

        return VStack(spacing: 4) {
            Text("기본 스탯")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 0) {
                // 헤더 행
                HStack(spacing: 0) {
                    statHeaderCell(label: "HP")
                    statHeaderCell(label: "Energy")
                    statHeaderCell(label: "Move")
                    statHeaderCell(label: "Attack")
                }
                .background(Color.cyan.opacity(0.15))

                // 값 행
                HStack(spacing: 0) {
                    statValueCell(value: stats.hp, color: .red)
                    statValueCell(value: stats.energy, color: .blue)
                    statValueCell(value: stats.moveSpeed, color: .green)
                    statValueCell(value: stats.attackSpeed, color: .orange)
                }
                .background(Color.white.opacity(0.03))
            }
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, 4)
    }

    // 스탯 헤더 셀
    private func statHeaderCell(label: String) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }

    // 스탯 값 셀
    private func statValueCell(value: Int, color: Color) -> some View {
        Text("\(value)")
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    // 요구사항 표
    private func requirementTable(title: String, currentValue: Int, requiredValue: Int, isMet: Bool, unit: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))

            // 표 헤더
            HStack(spacing: 0) {
                Text("현재 \(unit)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("필요 \(unit)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("충족")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.05))

            // 표 내용
            HStack(spacing: 0) {
                Text("\(currentValue)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(isMet ? .green : .white)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("\(requiredValue)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .frame(maxWidth: .infinity, alignment: .center)

                if isMet {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.vertical, 6)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 16) {
                Header(title: jobType.localizedDisplayName, showBackButton: false)

                // 해금되지 않은 직업 레이아웃
                VStack(spacing: 12) {
                    // 이미지
                    Image(jobType.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)

                    VStack(spacing: 4) {
                        // 직업 설명 (임시)
                        Text(getJobDescription(for: jobType))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }

                }

                Divider()

                // 직업 스탯 정보
                jobStatsView()

                Spacer()

                // 요구사항 표시
                if let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) {
                    VStack(spacing: 12) {
                        Text(String(format: "%@를 얻기 위한 조건", jobType.localizedDisplayName))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        // 레벨 요구사항 표
                        requirementTable(
                            title: "레벨 요구사항",
                            currentValue: currentLevel,
                            requiredValue: requirement.requiredLevel,
                            isMet: currentLevel >= requirement.requiredLevel,
                            unit: "레벨"
                        )

                        // 원소 요구사항 표
                        if let spiritType = SpiritType(rawValue: requirement.requiredSpirit) {
                            let currentCount = spiritCounts[spiritType] ?? 0
                            requirementTable(
                                title: String(format: "%@ 원소 요구사항", spiritType.localizedDisplayName),
                                currentValue: currentCount,
                                requiredValue: requirement.requiredCount,
                                isMet: currentCount >= requirement.requiredCount,
                                unit: String(format: "%@ 원소", spiritType.localizedDisplayName)
                            )
                        }
                    }
                }

                // 해금하기 버튼
                let canUnlock = canUnlockJob(jobType, currentLevel: currentLevel, spiritCounts: spiritCounts)
                PrimaryButton(
                    title: "직업 해금",
                    style: canUnlock ? .cyan : .disabled,
                    fullWidth: true
                ) {
                    if canUnlock {
                        onUnlock()
                    }
                }
                .disabled(!canUnlock)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea()
    }
}
