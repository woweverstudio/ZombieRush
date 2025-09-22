import SwiftUI

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router
    @Environment(UserStateManager.self) var userStateManager

    // 마켓 아이템 데이터 (UserStateManager에서 가져옴)
    private var marketItems: [MarketItem] {
        userStateManager.marketItems
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
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        Card(style: .cyberpunk) {
            VStack(spacing: 12) {
                switch item.type {
                case .fruitPackage(let count, let price):
                    NemoFruitIcon(size: .large)
                case .cheerBuff(let days, let price):
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
                        await purchaseItem()
                    }
                }) {
                    Text("구매")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(userStateManager.canAffordMarketItem(item) ? Color.cyan.opacity(0.8) : Color.gray.opacity(0.3))
                        )
                }
                .disabled(!userStateManager.canAffordMarketItem(item))
            }
        }
    }

    private func purchaseItem() async {
        let success = await userStateManager.purchaseMarketItem(item)
        if success {
            print("마켓 아이템 구매 완료: \(item.name)")
        } else {
            print("마켓 아이템 구매 실패: \(item.name)")
        }
    }
}

// MARK: - Preview
#Preview {
    MarketView()
}
