import SwiftUI

// MARK: - My Info Job Card Component
struct MyInfoJobCard: View {
    let jobType: JobType
    let isUnlocked: Bool
    let style: CardStyle
    let onTap: () -> Void

    init(
        jobType: JobType,
        isUnlocked: Bool,
        style: CardStyle = .cyberpunk,
        onTap: @escaping () -> Void
    ) {
        self.jobType = jobType
        self.isUnlocked = isUnlocked
        self.style = style
        self.onTap = onTap
    }

    var body: some View {
        Card(
            style: style,
            customBackgroundColor: .clear, // 배경을 투명하게 해서 이상한 색 없앰
            contentPadding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) // 패딩 최소화
        ) {
            VStack(spacing: 6) {
                Image(jobType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text(jobType.localizedDisplayName)
                    .font(.system(size: 11, weight: .medium, design: .monospaced)) // 폰트 크기 약간 줄임
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            onTap()
        }
    }
}
