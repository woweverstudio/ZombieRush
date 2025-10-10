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
            contentPadding: EdgeInsets(top: UIConstants.Spacing.x8, leading: UIConstants.Spacing.x8, bottom: UIConstants.Spacing.x8, trailing: UIConstants.Spacing.x8)
        ) {
            VStack(spacing: UIConstants.Spacing.x4) {
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
            // UI 피드백은 백그라운드에서 처리하여 응답성 향상
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            onTap()
        }
    }
}
