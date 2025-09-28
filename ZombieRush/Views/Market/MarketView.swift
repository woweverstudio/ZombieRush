import SwiftUI

extension MarketView {
    static let marketTitle = NSLocalizedString("market_title", tableName: "Market", comment: "Market title")
    static let nemoFruitPackageSection = NSLocalizedString("nemo_fruit_package_section", tableName: "Market", comment: "Nemo fruit package section")
    static let cheerBuffSection = NSLocalizedString("cheer_buff_section", tableName: "Market", comment: "Cheer buff section")
    static let purchaseButton = NSLocalizedString("purchase_button", tableName: "Market", comment: "Purchase button")
}

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    // 마켓 아이템 데이터
    private var marketItems: [MarketItem] {
        MarketItemsManager.marketItems
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 0) {
                headerView
                itemsGridView
            }
        }
    }

    // MARK: - Sub Views
    private var headerView: some View {
        Header(
            title: MarketView.marketTitle,
            badges: [.nemoFruits],
            onBack: {
                router.quitToMain()
            }
        )
    }

    private var itemsGridView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 네모열매 섹션
                VStack(alignment: .leading, spacing: 12) {
                    Text(verbatim: MarketView.nemoFruitPackageSection)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(marketItems.filter { item in
                            if case .fruitPackage = item.type { return true }
                            return false
                        }) { item in
                            MarketItemCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 네모의 응원 섹션
                VStack(alignment: .leading, spacing: 12) {
                    Text(verbatim: MarketView.cheerBuffSection)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(marketItems.filter { item in
                            if case .cheerBuff = item.type { return true }
                            return false
                        }) { item in
                            MarketItemCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Market Item Card
struct MarketItemCard: View {
    let item: MarketItem
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(GameKitManager.self) var gameKitManager

    var body: some View {
        Card(style: .cyberpunk) {
            VStack(spacing: 12) {
                switch item.type {
                case .fruitPackage(_, _):
                    NemoFruitIcon(size: .large)
                case .cheerBuff(_, _):
                    CheerBuffIcon(size: .large)
                }

                // 이름
                Text(item.name)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .multilineTextAlignment(.center)

                // 설명
                Text(item.description)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)

            // 가격
            HStack(spacing: 4) {
                if item.currencyType == .fruit {
                    NemoFruitIcon(size: .small)
                } else {
                    Image(systemName: "wonsign.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }

                Text("\(item.price)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(item.currencyType == .won ? .green : .yellow)
            }

                // 구매 버튼
                Button(action: {
                    Task {
                        switch item.type {
                        case .fruitPackage(let count, _):
                            // TODO: IAP
                            let request = AddNemoFruitsRequest(fruitsToAdd: count)
                            _ = await useCaseFactory.addNemoFruits.execute(request)
                        case .cheerBuff(let days, _):
                            let duration = TimeInterval(days * 24 * 60 * 60)
                            let request = PurchaseCheerBuffRequest(duration: duration)
                            _ = await useCaseFactory.purchaseCheerBuff.execute(request)
                        }
                    }
                }) {
                    Text(verbatim: MarketView.purchaseButton)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
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
}
