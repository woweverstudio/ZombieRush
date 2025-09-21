import SwiftUI

// MARK: - Job Info Card
struct JobInfoCard: View {
    let jobType: JobType
    let isUnlocked: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                                    .fill(Color.black.opacity(0.7))
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : (isUnlocked ? Color.white.opacity(0.2) : Color.gray.opacity(0.3)), lineWidth: 1)
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

// MARK: - Job Detail Panel
struct JobDetailPanel: View {
    let jobType: JobType

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: jobType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.cyan)

                Text(jobType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // 스텟 정보
            VStack(alignment: .leading, spacing: 12) {
                Text("기본 스텟")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)

                let stats = JobStats.getStats(for: jobType.rawValue)

                StatInfoRow(icon: "heart.fill", label: "체력", value: stats.hp)
                StatInfoRow(icon: "bolt.fill", label: "에너지", value: stats.energy)
                StatInfoRow(icon: "figure.run", label: "이동속도", value: stats.move)
                StatInfoRow(icon: "target", label: "공격속도", value: stats.attackSpeed)
            }

            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Stat Info Row
struct StatInfoRow: View {
    let icon: String
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 60, alignment: .leading)

            Spacer()

            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}
