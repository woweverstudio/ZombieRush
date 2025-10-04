import SwiftUI

// MARK: - Element Card Component
struct ElementCard: View {
    let spiritType: SpiritType
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Card(style: .cyberpunk) {
            HStack {
                VStack(spacing: 6){
                    Image(systemName: spiritType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(spiritType.color)
                        .frame(width: 32, height: 32)

                    Text(spiritType.localizedDisplayName)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.dsTextSecondary)
                }
                .frame(width: 60)

                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(8)
        }
        .frame(height: 80)
        .contentShape(Rectangle())
        .padding(.vertical, 6)
        .onTapGesture {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            onTap()
        }
    }
}
