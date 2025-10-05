import SwiftUI

extension JobUnlockSheet {
    static let jobUnlockButton = NSLocalizedString("my_info_job_unlock_button", tableName: "View", comment: "Job unlock button")
    static let basicStatsTitle = NSLocalizedString("my_info_basic_stats", tableName: "View", comment: "Basic stats title")
    
    static let currentValue = NSLocalizedString("my_info_current_value", tableName: "View", comment: "현재 %@")
    static let levelUnit = NSLocalizedString("level_unit", tableName: "View", comment: "레벨")
    static let requiredValue = NSLocalizedString("my_info_required_value", tableName: "View", comment: "필요한 %@")
    static let pass = NSLocalizedString("my_info_condition_pass", tableName: "View", comment: "조건 충족")
    static let unpass = NSLocalizedString("my_info_condition_unpass", tableName: "View", comment: "조건 미충족")
    
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
                        .frame(width: 160, height: 160)

                    VStack(spacing: 4) {
                        // 직업 설명
                        Text(jobType.localizedDescription)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }

                }

                JobStatTable(jobType: jobType, style: .default)
                
                Spacer()
                
                // 요구사항 표시
                if let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) {
                    VStack(spacing: 16) {

                        // 레벨 요구사항 표
                        RequirementsTable(
                            currentValue: currentLevel,
                            requiredValue: requirement.requiredLevel,
                            isMet: currentLevel >= requirement.requiredLevel,
                            unit: JobUnlockSheet.levelUnit
                        )

                        // 원소 요구사항 표
                        if let elementType = ElementType(rawValue: requirement.requiredElement) {
                            let currentCount = elementCounts[elementType] ?? 0
                            RequirementsTable(
                                currentValue: currentCount,
                                requiredValue: requirement.requiredCount,
                                isMet: currentCount >= requirement.requiredCount,
                                unit: elementType.localizedDisplayName
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
                    if canUnlock { onUnlock() }
                }
                .disabled(!canUnlock)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
    }
}
