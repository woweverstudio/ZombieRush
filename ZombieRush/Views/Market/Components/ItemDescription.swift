import SwiftUI

// MARK: - Item Description Component
struct ItemDescription: View {
    let item: MarketItem

    var body: some View {
        VStack(spacing: 8) {
            Text("상세 설명")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(item.description)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 6)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
