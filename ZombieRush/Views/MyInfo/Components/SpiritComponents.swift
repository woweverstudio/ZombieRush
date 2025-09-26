import SwiftUI

// MARK: - Spirit Info Card
struct SpiritInfoCard: View {
    let spiritType: SpiritType
    let isSelected: Bool
    let currentCount: Int
    let onTap: () -> Void

    var body: some View {
        SelectionInfoCard(
            title: spiritType.displayName,
            iconName: spiritType.iconName,
            iconColor: spiritType.color,
            value: "\(currentCount)",
            isSelected: isSelected,
            action: onTap
        )
    }
}

// MARK: - Spirit Detail Panel
struct SpiritDetailPanel: View {
    let spiritType: SpiritType
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(GameKitManager.self) var gameKitManager

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
                    .foregroundColor(Color.dsTextPrimary)

                Spacer()

                // 현재 개수 표시
                Text("\(getCurrentSpiritCount())마리")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(spiritType.color)
            }

            Divider()
                .background(Color.dsTextSecondary.opacity(0.3))

            Text(spiritType.description)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            
            Spacer()

            // 수량 선택
            VStack(alignment: .leading, spacing: 12) {
                Text("구매 수량")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)

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
                    QuantityButton(quantity: userRepository.currentUser?.nemoFruit ?? 0, isSelected: selectedQuantity == (userRepository.currentUser?.nemoFruit ?? 0), label: "최대") {
                        selectedQuantity = userRepository.currentUser?.nemoFruit ?? 0
                    }
                }
            }

            // 구매 버튼
            PrimaryButton(
                title: "정령 얻기",
                style: canAfford() ? .cyan : .disabled,
                trailingContent: {
                    NemoFruitCost(count: selectedQuantity)
                        .foregroundColor(canAfford() ? .yellow : .gray.opacity(0.5))
                },
                action: {
                    Task {
                        await purchaseSpirits()
                    }
                }
            )
        }
        .padding(20)
    }



    private func canAfford() -> Bool {
        let currentFruits = userRepository.currentUser?.nemoFruit ?? 0
        return currentFruits >= selectedQuantity
    }

    private func purchaseSpirits() async {
        let request = ConsumeNemoFruitsRequest(fruitsToConsume: selectedQuantity)
        let response = await useCaseFactory.consumeNemoFruits.execute(request)
        
        if response.success {
            let request = AddSpiritRequest(spiritType: spiritType, count: selectedQuantity)
            let _ = await useCaseFactory.addSpirit.execute(request)            
        } else {
            
        }
    }

    private func getCurrentSpiritCount() -> Int {
        guard let spirits = spiritsRepository.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
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
        SecondaryButton(
            title: label ?? "\(quantity)",
            style: isSelected ? .selected : .default,
            action: action
        )
    }
}
