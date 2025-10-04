import SwiftUI

extension JobUnlockSheet {
    static let jobUnlockConditions = NSLocalizedString("my_info_job_unlock_conditions", tableName: "View", comment: "Job unlock conditions")
    static let jobUnlockButton = NSLocalizedString("my_info_job_unlock_button", tableName: "View", comment: "Job unlock button")
    static let basicStatsTitle = NSLocalizedString("my_info_basic_stats", tableName: "View", comment: "Basic stats title")
    static let currentValue = NSLocalizedString("my_info_current_value", tableName: "View", comment: "Current value label")
    static let requiredValue = NSLocalizedString("my_info_required_value", tableName: "View", comment: "Required value label")
    static let fulfilled = NSLocalizedString("my_info_fulfilled", tableName: "View", comment: "Fulfilled status")
    static let levelRequirement = NSLocalizedString("my_info_level_requirement", tableName: "View", comment: "Level requirement title")
    static let elementRequirement = NSLocalizedString("my_info_element_requirement", tableName: "View", comment: "Element requirement title with placeholder")
    static let elementUnit = NSLocalizedString("my_info_element_unit", tableName: "View", comment: "Element unit with placeholder")
    static let levelUnit = NSLocalizedString("level_unit", tableName: "View", comment: "Level unit")
    static let hp = NSLocalizedString("models_stat_hp_name", tableName: "Common", comment: "HP stat name")
    static let energy = NSLocalizedString("models_stat_energy_name", tableName: "Common", comment: "Energy stat name")
    static let moveSpeed = NSLocalizedString("models_stat_move_speed_name", tableName: "Common", comment: "Move speed stat name")
    static let attackSpeed = NSLocalizedString("models_stat_attack_speed_name", tableName: "Common", comment: "Attack speed stat name")
}

// MARK: - Job Unlock Sheet
struct JobUnlockSheet: View {
    let jobType: JobType
    let currentLevel: Int
    let elementCounts: [ElementType: Int]
    let onUnlock: () -> Void


    // 직업 해금 가능 여부 확인
    private func canUnlockJob(_ jobType: JobType, currentLevel: Int, elementCounts: [ElementType: Int]) -> Bool {
        guard let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) else {
            return false
        }

        let levelMet = currentLevel >= requirement.requiredLevel

        if let elementType = ElementType(rawValue: requirement.requiredElement) {
            let elementMet = elementCounts[elementType] ?? 0 >= requirement.requiredCount
            return levelMet && elementMet
        }

        return levelMet
    }

    // 직업 스탯 정보 뷰
    private func jobStatsView() -> some View {
        let stats = JobStats.getStats(for: jobType.rawValue)

        return VStack(spacing: 4) {
            Text(JobUnlockSheet.basicStatsTitle)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 0) {
                // 헤더 행
                HStack(spacing: 0) {
                    statHeaderCell(label: JobUnlockSheet.hp)
                    statHeaderCell(label: JobUnlockSheet.energy)
                    statHeaderCell(label: JobUnlockSheet.moveSpeed)
                    statHeaderCell(label: JobUnlockSheet.attackSpeed)
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
                Text(String(format: JobUnlockSheet.currentValue, unit))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(String(format: JobUnlockSheet.requiredValue, unit))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(JobUnlockSheet.fulfilled)
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
                        // 직업 설명
                        Text(jobType.localizedDescription)
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
                        Text(String(format: JobUnlockSheet.jobUnlockConditions, jobType.localizedDisplayName))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        // 레벨 요구사항 표
                        requirementTable(
                            title: JobUnlockSheet.levelRequirement,
                            currentValue: currentLevel,
                            requiredValue: requirement.requiredLevel,
                            isMet: currentLevel >= requirement.requiredLevel,
                            unit: JobUnlockSheet.levelUnit
                        )

                        // 원소 요구사항 표
                        if let elementType = ElementType(rawValue: requirement.requiredElement) {
                            let currentCount = elementCounts[elementType] ?? 0
                            requirementTable(
                                title: String(format: JobUnlockSheet.elementRequirement, elementType.localizedDisplayName),
                                currentValue: currentCount,
                                requiredValue: requirement.requiredCount,
                                isMet: currentCount >= requirement.requiredCount,
                                unit: String(format: JobUnlockSheet.elementUnit, elementType.localizedDisplayName)
                            )
                        }
                    }
                }

                // 해금하기 버튼
                let canUnlock = canUnlockJob(jobType, currentLevel: currentLevel, elementCounts: elementCounts)
                    PrimaryButton(
                        title: JobUnlockSheet.jobUnlockButton,
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
