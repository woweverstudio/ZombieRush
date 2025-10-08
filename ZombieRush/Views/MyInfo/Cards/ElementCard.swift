import SwiftUI

// MARK: - Element Card Component
struct ElementCard: View {
    let elementType: ElementType
    let count: Int
    let style: CardStyle
    let onTap: () -> Void

    init(
        elementType: ElementType,
        count: Int,
        style: CardStyle = .cyberpunk,
        onTap: @escaping () -> Void
    ) {
        self.elementType = elementType
        self.count = count
        self.style = style
        self.onTap = onTap
    }

    var body: some View {
        Card(style: style) {
            HStack {
                VStack(spacing: 6){
                    Image(systemName: elementType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(elementType.color)
                        .frame(width: 32, height: 32)

                    Text(elementType.localizedDisplayName)
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
