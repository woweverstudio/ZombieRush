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
            VStack(alignment: .leading, spacing: 6) {
                ForEach(messages, id: \.self) { message in
                    Text(bulletPoint + " " + message)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Preview
#Preview {
    TrustInfoCard(
        messages: [
            "Purchases are securely processed through the App Store.",
            "Purchased NEMO Jams are applied to your account instantly.",
            "Prices may vary by region and currency."
        ]
    )
    .padding()
    .background(Color.black)
}
