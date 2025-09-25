import SwiftUI

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
            title: "MARKET",
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
                    Text("네모열매 패키지")
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
                    Text("네모의 응원")
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
                case .fruitPackage(let _, let _):
                    NemoFruitIcon(size: .large)
                case .cheerBuff(let _, let _):
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
                        let request = PurchaseMarketItemRequest(item: item)
                        _ = try? await useCaseFactory.purchaseMarketItem.execute(request)
                    }
                }) {
                    Text("구매")
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
