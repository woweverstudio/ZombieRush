import Foundation

// MARK: - Market Category
enum MarketCategory: String, CaseIterable {
    case skins = "스킨"
    case weapons = "무기"
}

// MARK: - Unified Market Item (스킨과 무기를 통합)
enum MarketItem: Identifiable {
    case skin(SkinItem)
    case weapon(WeaponItem)

    // Equatable 구현
    static func == (lhs: MarketItem, rhs: MarketItem) -> Bool {
        switch (lhs, rhs) {
        case (.skin(let leftItem), .skin(let rightItem)):
            return leftItem.id == rightItem.id
        case (.weapon(let leftItem), .weapon(let rightItem)):
            return leftItem.id == rightItem.id
        case (.skin, .weapon), (.weapon, .skin):
            return false
        }
    }

    var id: UUID {
        switch self {
        case .skin(let item): return item.id
        case .weapon(let item): return item.id
        }
    }

    var name: String {
        switch self {
        case .skin(let item): return item.name
        case .weapon(let item): return item.name
        }
    }

    var description: String {
        switch self {
        case .skin(let item): return item.description
        case .weapon(let item): return item.description
        }
    }

    var price: Int {
        switch self {
        case .skin(let item): return item.price
        case .weapon(let item): return item.price
        }
    }

    var iconName: String {
        switch self {
        case .skin(let item): return item.iconName
        case .weapon(let item): return item.iconName
        }
    }

    var isPurchased: Bool {
        switch self {
        case .skin(let item): return item.isPurchased
        case .weapon(let item): return item.isPurchased
        }
    }

    var category: MarketCategory {
        switch self {
        case .skin: return .skins
        case .weapon: return .weapons
        }
    }

    // 스킨 효과 (스킨일 때만 유효)
    var healthBonus: Int {
        switch self {
        case .skin(let item): return item.healthBonus
        case .weapon: return 0
        }
    }

    var ammoBonus: Int {
        switch self {
        case .skin(let item): return item.ammoBonus
        case .weapon: return 0
        }
    }

    var speedBonus: Int {
        switch self {
        case .skin(let item): return item.speedBonus
        case .weapon: return 0
        }
    }

    // 무기 효과 (무기일 때만 유효)
    var attackSpeedBonus: Double {
        switch self {
        case .skin: return 1.0
        case .weapon(let item): return item.attackSpeedBonus
        }
    }

    var bulletCountBonus: Int {
        switch self {
        case .skin: return 0
        case .weapon(let item): return item.bulletCountBonus
        }
    }

    var penetrationBonus: Int {
        switch self {
        case .skin: return 0
        case .weapon(let item): return item.penetrationBonus
        }
    }
}
