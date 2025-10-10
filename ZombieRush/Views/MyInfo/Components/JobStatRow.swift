import SwiftUI

// MARK: - Job Stat Row Component
struct JobStatRow: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color
    let style: JobStatTable.Style

    var body: some View {
        HStack(spacing: 0) {
            // 스탯 이름 (아이콘 + 라벨)
            HStack(spacing: UIConstants.Spacing.x8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12))

                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, UIConstants.Spacing.x4)

            // 스탯 값
            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            .frame(width: 60, alignment: .center)
            .padding(.vertical, style == .default ? UIConstants.Spacing.x8 : UIConstants.Spacing.x4)
        }
        .padding(.vertical, style == .default ? UIConstants.Spacing.x4 : UIConstants.Spacing.x4)
    }
}


