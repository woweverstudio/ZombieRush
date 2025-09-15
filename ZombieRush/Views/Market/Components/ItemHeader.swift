import SwiftUI

// MARK: - Item Header Component (아이콘, 이름, 카테고리)
struct ItemHeader: View {
    let item: MarketItem

    var body: some View {
        VStack(spacing: 12) {
            // 큰 아이콘
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .stroke(item.isPurchased ? Color.green : Color.cyan, lineWidth: 2)
                    )
                    .shadow(color: (item.isPurchased ? Color.green : Color.cyan).opacity(0.6), radius: 8, x: 0, y: 0)

                Image(systemName: item.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(item.isPurchased ? .green : .cyan)

                if item.isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                        .offset(x: 32, y: -32)
                }
            }

            // 아이템 이름
            Text(item.name)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // 카테고리
            Text(item.category.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                )
        }
    }
}
