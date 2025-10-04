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
                    
                }
                .scrollIndicators(.hidden)
            }
            .padding()
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
        Card(style: .cyberpunk) {
            VStack(alignment: .leading, spacing: 6) {
                Text("• " + MarketView.trustMessage1)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))

                Text("• " + MarketView.trustMessage2)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))

                Text("• " + MarketView.trustMessage3)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Market Item Card
struct MarketItemCard: View {
    let item: MarketItem

    private var localizedName: String {
        // 한국어 환경에서는 한국어 이름, 그 외에는 영어 이름 사용
        Locale.current.language.languageCode?.identifier == "ko" ? item.name : item.englishName
    }

    private var localizedDescription: String {
        switch item.descriptionKey {
        case "market_item_description_20":
            return NSLocalizedString("market_item_description_20", tableName: "View", comment: "")
        case "market_item_description_55":
            return NSLocalizedString("market_item_description_55", tableName: "View", comment: "")
        case "market_item_description_120":
            return NSLocalizedString("market_item_description_120", tableName: "View", comment: "")
        default:
            return item.descriptionKey
        }
    }

    private var displayPrice: String {
        // TODO: StoreKit 구현 후 product.displayPrice 사용
        // 현재는 임시로 하드코딩된 가격 표시
        "₩\(item.price)"
    }

    var body: some View {
        Card(style: .cyberpunk) {
            VStack(spacing: 16) {
                // 네모잼 아이콘
                Image("gem_package")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)

                // 아이템 이름
                Text(localizedName)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .multilineTextAlignment(.center)

                // 설명 문구
                Text(localizedDescription)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 40)

                // 구매 버튼
                Button(action: {
                    // TODO: StoreKit 구매 로직 구현
                }) {
                    Text(MarketView.purchaseButton)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan.opacity(0.8))
                        )
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Preview
#Preview {
    MarketView()
        .environment(AppRouter())
}
