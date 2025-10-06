import SwiftUI

extension MarketEmptyStateCard {
    static let title = NSLocalizedString("market_unavailable_title", tableName: "View", comment: "Market unavailable title")
    static let message = NSLocalizedString("market_unavailable_message", tableName: "View", comment: "Market unavailable message")
}

// MARK: - Market Empty State Card
struct MarketEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "cart.badge.questionmark")
                    .font(.system(size: 32))
                    .foregroundColor(.cyan.opacity(0.7))
            }

            VStack(spacing: 8) {
                Text(MarketEmptyStateCard.title)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.dsTextPrimary)
                    .multilineTextAlignment(.center)

                Text(MarketEmptyStateCard.message)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.dsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .frame(minHeight: 300)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    MarketEmptyStateCard()
        .background(Color.black)
}
