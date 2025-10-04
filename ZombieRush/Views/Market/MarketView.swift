import SwiftUI

extension MarketView {
    static let marketTitle = NSLocalizedString("screen_title_market", tableName: "View", comment: "Market screen title")
    static let promotionTitle = NSLocalizedString("market_promotion_title", tableName: "View", comment: "Market promotion title")
    static let promotionDescription = NSLocalizedString("market_promotion_description", tableName: "View", comment: "Market promotion description")
    static let purchaseButton = NSLocalizedString("market_purchase_button", tableName: "View", comment: "Market purchase button")
    static let purchaseButtonTemplate = NSLocalizedString("market_purchase_button_template", tableName: "View", comment: "Market purchase button template")
    static let trustMessage1 = NSLocalizedString("market_trust_message_1", tableName: "View", comment: "Market trust message 1")
    static let trustMessage2 = NSLocalizedString("market_trust_message_2", tableName: "View", comment: "Market trust message 2")
    static let trustMessage3 = NSLocalizedString("market_trust_message_3", tableName: "View", comment: "Market trust message 3")
}

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router

    // 마켓 아이템 데이터 (젬만)
    private var gemItems: [MarketItem] {
        MarketItemsManager.marketItems.filter { item in
            if case .gemPackage = item.type { return true }
            return false
        }
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()
            
            VStack {
                headerView
                ScrollView {
                    VStack(spacing: 24) {
                        promotionSection
                        itemsGridView
                        trustSection
                    }
                    .padding(.vertical, 32)
                }
                .scrollIndicators(.hidden)
            }
            .padding()            
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Sub Views
    private var promotionSection: some View {
        VStack(spacing: 6) {
            Text(MarketView.promotionTitle)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
                .multilineTextAlignment(.center)
                .shadow(color: Color.cyan, radius: 3, x: 0, y: 0)

            Text(MarketView.promotionDescription)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var headerView: some View {
        Header(
            title: MarketView.marketTitle,
            badges: [.gem],
            onBack: {
                router.goBack()
            }
        )
    }

    private var itemsGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(gemItems) { item in
                MarketItemCard(item: item)
            }
        }
    }

    private var trustSection: some View {
        TrustInfoCard(
            messages: [
                MarketView.trustMessage1,
                MarketView.trustMessage2,
                MarketView.trustMessage3
            ]
        )
    }
}


// MARK: - Preview
#Preview {
    MarketView()
        .environment(AppRouter())
}
