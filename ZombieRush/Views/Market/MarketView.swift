import SwiftUI

// MARK: - Market Item Type
enum MarketItemType {
    case fruitPackage(count: Int, price: Int)
}

// MARK: - Market Item
struct MarketItem: Identifiable {
    let id = UUID()
    let type: MarketItemType
    let name: String
    let description: String
    let iconName: String
    let price: Int
    let currencyType: CurrencyType

    enum CurrencyType {
        case won
        case fruit
    }
}

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router
    @Environment(UserStateManager.self) var userStateManager

    // 마켓 아이템 데이터
    private var marketItems: [MarketItem] {
        [
            // 네모열매 패키지
            MarketItem(
                type: .fruitPackage(count: 20, price: 2000),
                name: "네모열매 20개",
                description: "네모열매 20개를 즉시 충전",
                iconName: "diamond.fill",
                price: 2000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 55, price: 5000),
                name: "네모열매 55개",
                description: "네모열매 55개를 즉시 충전 (약 15% 보너스)",
                iconName: "diamond.fill",
                price: 5000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 110, price: 10000),
                name: "네모열매 110개",
                description: "네모열매 110개를 즉시 충전 (약 10% 보너스)",
                iconName: "diamond.fill",
                price: 10000,
                currencyType: .won
            )
        ]
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
                // 아이콘
                Image(systemName: item.iconName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(item.currencyType == .won ? .yellow : .cyan)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.dsSurface)
                            .overlay(
                                Circle()
                                    .stroke(item.currencyType == .won ? Color.neonYellow.opacity(0.5) : Color.cyan.opacity(0.5), lineWidth: 2)
                            )
                    )

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
                    Image(systemName: item.currencyType == .won ? "wonsign.circle.fill" : "diamond.fill")
                        .font(.system(size: 12))
                        .foregroundColor(item.currencyType == .won ? .green : .yellow)

                    Text("\(item.price)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(item.currencyType == .won ? .green : .yellow)
                }

                // 구매 버튼
                Button(action: {
                    purchaseItem()
                }) {
                    Text("구매")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(canAfford() ? Color.cyan.opacity(0.8) : Color.gray.opacity(0.3))
                        )
                }
                .disabled(!canAfford())
            }
        }
    }

    private func canAfford() -> Bool {
        switch item.currencyType {
        case .won:
            // 실제 현금 구매는 나중에 구현
            return true
        case .fruit:
            return userStateManager.nemoFruits >= item.price
        }
    }

    private func purchaseItem() {
        switch item.type {
        case .fruitPackage(count: let count, price: _):
            // 네모열매 패키지 구매 (실제 IAP는 나중에 구현)
            print("네모열매 \(count)개 패키지 구매 (₩\(item.price))")
            Task {
                let success = await userStateManager.addNemoFruits(count)
                if success {
                    print("네모열매 \(count)개 지급 완료")
                }
            }
            // TODO: IAP 구현 후 실제 결제 처리
        }
    }
}

// MARK: - Preview
#Preview {
    MarketView()
}
