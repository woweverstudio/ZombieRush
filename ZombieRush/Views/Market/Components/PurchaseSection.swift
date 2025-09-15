import SwiftUI

// MARK: - Purchase Section Component
struct PurchaseSection: View {
    let item: MarketItem

    var body: some View {
        VStack(spacing: 0) {
            if item.isPurchased {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)

                    Text("이미 보유하고 있습니다")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
                .padding(.vertical, 12)
            } else {
                VStack(spacing: 12) {
                    // 가격 정보
                    HStack(spacing: 6) {
                        Text("가격:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        HStack(spacing: 3) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                            Text("\(item.price)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                    }

                    // 구매 버튼
                    NeonButton("구매하기", style: .cyan, fullWidth: true, size: .small) {
                        // 구매 로직 구현 (추후 확장)
                        print("구매: \(item.name)")
                    }
                    .disabled(true) // 현재는 비활성화 (샘플용)
                    .opacity(0.6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}
