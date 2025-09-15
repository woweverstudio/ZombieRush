import Foundation

// MARK: - Weapon Item Model
struct WeaponItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let price: Int
    let iconName: String
    let isPurchased: Bool

    // 무기 효과
    let attackSpeedBonus: Double  // 공격 속도 증가 (배율, 예: 1.2 = 20% 증가)
    let bulletCountBonus: Int     // 총알 개수 증가
    let penetrationBonus: Int     // 관통수 증가

    init(name: String, description: String, price: Int, iconName: String, isPurchased: Bool = false, attackSpeedBonus: Double = 1.0, bulletCountBonus: Int = 0, penetrationBonus: Int = 0) {
        self.name = name
        self.description = description
        self.price = price
        self.iconName = iconName
        self.isPurchased = isPurchased
        self.attackSpeedBonus = attackSpeedBonus
        self.bulletCountBonus = bulletCountBonus
        self.penetrationBonus = penetrationBonus
    }
}
