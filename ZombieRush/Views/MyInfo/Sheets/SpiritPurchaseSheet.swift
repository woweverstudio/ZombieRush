import SwiftUI

// MARK: - Spirit Purchase Sheet
struct SpiritPurchaseSheet: View {
    let spiritType: SpiritType
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
                Header(title: "원소 구입", showBackButton: false)

                // 원소 정보
                HStack(spacing: 12) {
                    Image(systemName: spiritType.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(spiritType.color)

                    VStack(alignment:.leading, spacing: 8) {
                        Text(spiritType.localizedDisplayName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text(spiritType.localizedDescription)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Divider()
                Spacer()
                
                // 교환 문구
                Text(String(format: "네모잼 %d개로 %@ 원소 %d 개를 교환합니다.", purchaseCount, spiritType.localizedDisplayName, purchaseCount))
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
                        Text("➔")
                        CommonBadge(image: Image(systemName: spiritType.iconName), value: purchaseCount, size: 28, color: spiritType.color)
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
                    title: hasEnoughNemoFruits ? "원소 얻기" : "네모잼 부족",
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
