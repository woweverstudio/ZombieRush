import SwiftUI

// MARK: - Trust Info Card Component
struct TrustInfoCard: View {
    let messages: [String]
    let style: CardStyle
    let bulletPoint: String

    init(
        messages: [String],
        style: CardStyle = .cyberpunk,
        bulletPoint: String = "•"
    ) {
        self.messages = messages
        self.style = style
        self.bulletPoint = bulletPoint
    }

    var body: some View {
        Card(style: style) {
            VStack(alignment: .leading, spacing: UIConstants.Spacing.x8) {
                ForEach(messages, id: \.self) { message in
                    HStack(alignment: .top, spacing: UIConstants.Spacing.x8) {
                        Text(bulletPoint)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))

                        Text(message)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(UIConstants.Spacing.x8)
        }
    }
}

// MARK: - Preview
#Preview {
    TrustInfoCard(
        messages: [
            "Purchases are securely processed through the App Store.",
            "Purchased NEMO Jams are applied to your account instantly.",
            "Prices may vary by region and currency.",
            "This consumable digital item is non-refundable once delivered.\nRefunds may be issued only in cases of technical failure or delivery issues."
        ]
    )
    .padding()
    .background(Color.black)
}
