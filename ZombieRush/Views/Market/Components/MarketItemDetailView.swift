import SwiftUI

// MARK: - Market Item Detail View (우측 상세정보용)
struct MarketItemDetailView: View {
    let item: MarketItem

    var body: some View {
        VStack(spacing: 12) {
            // 상단: 이미지 + 효과 (HStack)
            HStack(alignment: .top, spacing: 12) {
                // 왼쪽: 이미지 (축소)
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(item.isPurchased ? Color.green : Color.cyan, lineWidth: 2)
                            )
                            .shadow(color: (item.isPurchased ? Color.green : Color.cyan).opacity(0.6), radius: 6, x: 0, y: 0)

                        Image(systemName: item.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(item.isPurchased ? .green : .cyan)

                        if item.isPurchased {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .offset(x: 25, y: -25)
                        }
                    }

                    // 아이템 이름 (축소)
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    // 카테고리 (축소)
                    Text(item.category.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .frame(width: 90)

                // 우측: 효과 섹션
                VStack(alignment: .leading, spacing: 8) {
                    if item.category == .skins {
                        SkinEffectsSection(item: item)
                    } else if item.category == .weapons {
                        WeaponEffectsSection(item: item)
                    }

                    Spacer()
                }
            }

            // 하단: 가격 + 구매 버튼
            PurchaseSection(item: item)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

