import SwiftUI

extension JobOwnedSheet {
    static let basicStatsTitle = NSLocalizedString("my_info_basic_stats", tableName: "View", comment: "Basic stats title")
    
    static let hp = NSLocalizedString("models_stat_hp_name", tableName: "Common", comment: "HP stat name")
    static let energy = NSLocalizedString("models_stat_energy_name", tableName: "Common", comment: "Energy stat name")
    static let moveSpeed = NSLocalizedString("models_stat_move_speed_name", tableName: "Common", comment: "Move speed stat name")
    static let attackSpeed = NSLocalizedString("models_stat_attack_speed_name", tableName: "Common", comment: "Attack speed stat name")
    
    static let confirmButton = NSLocalizedString("confirm_button", tableName: "Common", comment: "Confirm button")
}

// MARK: - Job Owned Sheet
struct JobOwnedSheet: View {
    @Environment(\.dismiss) var dismiss
    let jobType: JobType

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 16) {
                Header(title: jobType.localizedDisplayName, showBackButton: false)

                // 이미 해금된 직업 - 큰 이미지로 표시
                VStack(spacing: 16) {
                    // 큰 이미지
                    Image(jobType.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                    VStack(spacing: 8) {
                        // 직업 설명
                        Text(jobType.localizedDescription)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    
                    Divider()

                    // 직업 스탯 정보
                    JobStatTable(jobType: jobType, style: .default)
                    
                    Spacer()
                    
                    PrimaryButton(title: JobOwnedSheet.confirmButton) {
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
    }
}
