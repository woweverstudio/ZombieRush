import SwiftUI

extension MarketView {
    static let marketTitle = NSLocalizedString("screen_title_market", tableName: "View", comment: "Market screen title")
    static let purchaseButton = NSLocalizedString("market_purchase_button", tableName: "View", comment: "Market purchase button")
}

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router

    // 마켓 아이템 데이터 (네모잼만)
    private var jamItems: [MarketItem] {
        MarketItemsManager.marketItems.filter { item in
            if case .jamPackage = item.type { return true }
            return false
        }
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 20) {
                headerView
                itemsGridView
            }
            .padding()
        }
    }

    // MARK: - Sub Views
    private var headerView: some View {
        Header(
            title: MarketView.marketTitle,
            badges: [.nemoJam],
            onBack: {
                router.goBack()
            }
        )
    }

    private var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(jamItems) { item in
                    MarketItemCard(item: item)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Market Item Card
struct MarketItemCard: View {
    let item: MarketItem

    var body: some View {
        Card(style: .cyberpunk) {
            VStack(spacing: 12) {
                // 네모잼 아이콘
                Image("nemo_package")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)

                // 이름
                Text(item.name)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .multilineTextAlignment(.center)

                // 설명
                Text(item.description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(height: 45)

                // 가격
                HStack(spacing: 4) {
                    Image(systemName: "wonsign.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)

                    Text("\(item.price)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }

                // 구매 버튼
                Button(action: {
                    // TODO: 구매 로직 구현
                }) {
                    Text(MarketView.purchaseButton)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan.opacity(0.8))
                        )
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MarketView()
        .environment(AppRouter())
}
