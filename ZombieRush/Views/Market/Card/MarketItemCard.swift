import SwiftUI

// MARK: - Market Item Card Component
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
            VStack(spacing: 24) {
                HStack(spacing: 20) {
                    Image("gem_package")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(localizedName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.dsTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        // 설명 문구
                        Text(localizedDescription)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // ✅ 줄 제한 해제
                            .fixedSize(horizontal: false, vertical: true) // ✅ 세로로 크기 확장 허용
                    }
                }

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
    var gemItems: [MarketItem] {
        MarketItemsManager.marketItems.filter { item in
            if case .gemPackage = item.type { return true }
            return false
        }
    }
    
    VStack(spacing: 12) {
        ForEach(gemItems) { item in
            MarketItemCard(item: item)
                
        }
    }
    .padding(12)
    .background(Background())
    .environment(\.locale, .init(identifier: "ko"))
    
}

