import SwiftUI

// MARK: - Market Item Card Component
struct MarketItemCard: View {
    let item: GemItem
    @Environment(StoreKitManager.self) var storeKitManager
    @State private var isPurchasing = false

    var body: some View {
        Card(style: .cyberpunk) {
            VStack(spacing: UIConstants.Spacing.x24) {
                HStack(spacing: UIConstants.Spacing.x16) {
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)

                    VStack(alignment: .leading, spacing: UIConstants.Spacing.x16) {
                        Text(item.name)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.dsTextPrimary)
                            .multilineTextAlignment(.center)

                        // 설명 문구
                        Text(item.description)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // ✅ 줄 제한 해제
                            .fixedSize(horizontal: false, vertical: true) // ✅ 세로로 크기 확장 허용
                    }
                }
                
                PrimaryButton(title: item.price) {
                    Task {
                        isPurchasing = true
                        await storeKitManager.purchaseProduct(item.product)
                        isPurchasing = false
                    }
                }
                .disabled(isPurchasing)
            }
            .padding(.vertical, UIConstants.Spacing.x12)
            .padding(.horizontal, UIConstants.Spacing.x8)
        }
    }
}

