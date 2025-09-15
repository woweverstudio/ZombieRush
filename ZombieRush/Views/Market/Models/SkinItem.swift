import Foundation

// MARK: - Skin Item Model
struct SkinItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let price: Int
    let iconName: String
    let isPurchased: Bool

    // 스킨 효과
    let healthBonus: Int
    let ammoBonus: Int
    let speedBonus: Int

    init(name: String, description: String, price: Int, iconName: String, isPurchased: Bool = false, healthBonus: Int = 0, ammoBonus: Int = 0, speedBonus: Int = 0) {
        self.name = name
        self.description = description
        self.price = price
        self.iconName = iconName
        self.isPurchased = isPurchased
        self.healthBonus = healthBonus
        self.ammoBonus = ammoBonus
        self.speedBonus = speedBonus
    }
}
