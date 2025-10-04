import SwiftUI

extension JobOwnedSheet {
    static let basicStatsTitle = NSLocalizedString("my_info_basic_stats", tableName: "View", comment: "Basic stats title")
    
    static let hp = NSLocalizedString("models_stat_hp_name", tableName: "Common", comment: "HP stat name")
    static let energy = NSLocalizedString("models_stat_energy_name", tableName: "Common", comment: "Energy stat name")
    static let moveSpeed = NSLocalizedString("models_stat_move_speed_name", tableName: "Common", comment: "Move speed stat name")
    static let attackSpeed = NSLocalizedString("models_stat_attack_speed_name", tableName: "Common", comment: "Attack speed stat name")
}

// MARK: - Job Owned Sheet
struct JobOwnedSheet: View {
    let jobType: JobType

    // 직업 스탯 정보 뷰
    private func jobStatsView() -> some View {
        let stats = JobStats.getStats(for: jobType.rawValue)

        return VStack(spacing: 4) {
            Text(JobOwnedSheet.basicStatsTitle)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 0) {
                // 헤더 행
                HStack(spacing: 0) {
                    statHeaderCell(label: JobOwnedSheet.hp)
                    statHeaderCell(label: JobOwnedSheet.energy)
                    statHeaderCell(label: JobOwnedSheet.moveSpeed)
                    statHeaderCell(label: JobOwnedSheet.attackSpeed)
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

                    // 직업 스탯 정보
                    jobStatsView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea()
    }
}
