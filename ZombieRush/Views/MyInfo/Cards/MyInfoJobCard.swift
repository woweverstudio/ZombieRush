import SwiftUI

// MARK: - My Info Job Card Component
struct MyInfoJobCard: View {
    let jobType: JobType
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Card(style: isUnlocked ? .cyberpunk : .disabled) {
            VStack(spacing: 6) {
                Image(jobType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text(jobType.localizedDisplayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
            }
            .padding(6)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            onTap()
        }
    }
}
