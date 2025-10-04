import SwiftUI

extension ElementPurchaseSheet {
    static let purchaseTitle = NSLocalizedString("my_info_element_purchase_title", tableName: "View", comment: "Element purchase sheet title")
    static let exchangeDescription = NSLocalizedString("my_info_element_exchange_description", tableName: "View", comment: "Element exchange description")
    static let purchaseButton = NSLocalizedString("my_info_element_purchase_button", tableName: "View", comment: "Element purchase button")
    static let insufficientNemoFruits = NSLocalizedString("my_info_insufficient_nemo_fruits", tableName: "View", comment: "Insufficient nemo fruits message")
    static let exchangeArrow = NSLocalizedString("exchange_arrow", tableName: "View", comment: "Exchange arrow symbol")
}

// MARK: - Element Purchase Sheet
struct ElementPurchaseSheet: View {
    let elementType: ElementType
    @Binding var purchaseCount: Int
    let availableNemoFruits: Int
    let onPurchase: () -> Void

    private var hasEnoughNemoFruits: Bool {
        return availableNemoFruits >= purchaseCount
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 20) {
                Header(title: ElementPurchaseSheet.purchaseTitle, showBackButton: false)

                // 원소 정보
                HStack(spacing: 12) {
                    Image(systemName: elementType.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(elementType.color)

                    VStack(alignment:.leading, spacing: 8) {
                        Text(elementType.localizedDisplayName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text(elementType.localizedDescription)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Divider()
                Spacer()
                
                // 교환 문구
                Text(String(format: ElementPurchaseSheet.exchangeDescription, purchaseCount, elementType.localizedDisplayName, purchaseCount))
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                
                HStack(spacing: 16) {
                    SecondaryButton(title: "-", style: .default, fontSize: 24, size: .init(width: 60, height: 45)) {
                        if purchaseCount > 1 {
                            purchaseCount -= 1
                        }
                    }

                    HStack {
                        CommonBadge(image: Image("nemo_single"), value: purchaseCount, size: 28, color: .cyan)
                        Text(ElementPurchaseSheet.exchangeArrow)
                        CommonBadge(image: Image(systemName: elementType.iconName), value: purchaseCount, size: 28, color: elementType.color)
                    }

                    SecondaryButton(title: "+", style: .default, fontSize: 24, size: .init(width: 60, height: 45)) {
                        if purchaseCount < 99 {
                            purchaseCount += 1
                        }
                    }

                }
                .frame(maxWidth: .infinity)
                Divider()

                PrimaryButton(
                    title: hasEnoughNemoFruits ? ElementPurchaseSheet.purchaseButton : ElementPurchaseSheet.insufficientNemoFruits,
                    style: hasEnoughNemoFruits ? .cyan : .disabled,
                    fullWidth: true
                ) {
                    onPurchase()
                }
                .disabled(!hasEnoughNemoFruits)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
        .presentationDetents([.medium])
    }
}
