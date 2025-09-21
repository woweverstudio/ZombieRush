import SwiftUI

// MARK: - Spirit Info Card
struct SpiritInfoCard: View {
    let spiritType: SpiritType
    let isSelected: Bool
    let currentCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 정령 아이콘
                Image(systemName: spiritType.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(spiritType.color)
                    .frame(width: 50, height: 50)

                // 정령 이름
                Text(spiritType.displayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 현재 개수
                Text("\(currentCount)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Spirit Detail Panel
struct SpiritDetailPanel: View {
    let spiritType: SpiritType
    @Environment(SpiritsStateManager.self) var spiritsStateManager
    @Environment(UserStateManager.self) var userStateManager

    @State private var selectedQuantity: Int = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: spiritType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(spiritType.color)
                    .frame(width: 32, height: 32)

                Text(spiritType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // 현재 개수 표시
                Text("\(getCurrentSpiritCount())마리")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)
            }

            Divider()
                .background(Color.white.opacity(0.3))

            Text(spiritType.description)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            

            // 수량 선택
            VStack(alignment: .leading, spacing: 12) {
                Text("구매 수량")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)

                HStack(spacing: 8) {
                    QuantityButton(quantity: 1, isSelected: selectedQuantity == 1) {
                        selectedQuantity = 1
                    }
                    QuantityButton(quantity: 5, isSelected: selectedQuantity == 5) {
                        selectedQuantity = 5
                    }
                    QuantityButton(quantity: 10, isSelected: selectedQuantity == 10) {
                        selectedQuantity = 10
                    }
                    QuantityButton(quantity: 25, isSelected: selectedQuantity == 25) {
                        selectedQuantity = 25
                    }
                    QuantityButton(quantity: maxPurchasableQuantity(), isSelected: selectedQuantity == maxPurchasableQuantity(), label: "최대") {
                        selectedQuantity = maxPurchasableQuantity()
                    }
                }
            }

            // 구매 버튼
            Button(action: {
                // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
                DispatchQueue.global(qos: .userInteractive).async {
                    AudioManager.shared.playButtonSound()
                    HapticManager.shared.playButtonHaptic()
                }

                Task {
                    await purchaseSpirits()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(canAfford() ? spiritType.color : .gray.opacity(0.5))

                    Text("정령 얻기")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(canAfford() ? .white : .gray.opacity(0.5))

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 12))
                            .foregroundColor(canAfford() ? .cyan : .gray.opacity(0.5))

                        Text("\(selectedQuantity)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(canAfford() ? .cyan : .gray.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canAfford() ?
                              spiritType.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(canAfford() ?
                                        spiritType.color.opacity(0.5) : Color.gray.opacity(0.3),
                                        lineWidth: 1)
                        )
                )
            }
            .disabled(!canAfford())
        }
        .padding(20)
    }

    private func getCurrentSpiritCount() -> Int {
        guard let spirits = spiritsStateManager.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }

    private func maxPurchasableQuantity() -> Int {
        return userStateManager.nemoFruits
    }

    private func canAfford() -> Bool {
        return userStateManager.nemoFruits >= selectedQuantity
    }

    private func purchaseSpirits() async {
        guard canAfford() else {
            print("💎 Spirit: 네모열매가 부족합니다")
            return
        }

        // 네모열매 차감
        let success = await userStateManager.consumeNemoFruits(selectedQuantity)
        if success {
            // 정령 추가
            await spiritsStateManager.addSpirit(spiritType, count: selectedQuantity)
            print("🔥 Spirit: \(spiritType.displayName) \(selectedQuantity)마리 구매 완료")
        } else {
            print("💎 Spirit: 네모열매 차감 실패")
        }
    }
}

// MARK: - Quantity Button
struct QuantityButton: View {
    let quantity: Int
    let isSelected: Bool
    var label: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label ?? "\(quantity)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 50, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? Color.cyan : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                )
        }
    }
}
