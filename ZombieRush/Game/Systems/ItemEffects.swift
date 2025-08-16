import Foundation
import SpriteKit

// MARK: - Item Effect Factory
class ItemEffectFactory {
    static func createEffect(for type: ItemType) -> ItemEffect {
        switch type {
        case .speedBoost:
            return SpeedBoostEffect()
        case .healthRestore:
            return HealthRestoreEffect()
        case .ammoRestore:
            return AmmoRestoreEffect()
        case .invincibility:
            return InvincibilityEffect()
        case .shotgun:
            return ShotgunEffect()
        case .meteor:
            return MeteorEffect()
        }
    }
}

// MARK: - Concrete Effects

// 이동속도 증가 효과
class SpeedBoostEffect: ItemEffect {
    let duration: TimeInterval = GameConstants.Items.buffDuration
    let isInstant: Bool = false
    
    func apply(to player: Player) {
        player.applySpeedBoost(multiplier: GameConstants.Items.speedMultiplier)
    }
    
    func remove(from player: Player) {
        player.removeSpeedBoost()
    }
}

// 체력회복 효과
class HealthRestoreEffect: ItemEffect {
    let duration: TimeInterval = 0
    let isInstant: Bool = true
    
    func apply(to player: Player) {
        player.restoreHealth(amount: GameConstants.Items.healthRestoreAmount)
    }
    
    func remove(from player: Player) {
        // 즉시 효과는 제거할 것이 없음
    }
}

// 탄약 충전 효과
class AmmoRestoreEffect: ItemEffect {
    let duration: TimeInterval = 0
    let isInstant: Bool = true
    
    func apply(to player: Player) {
        player.restoreAmmo(amount: GameConstants.Items.ammoRestoreAmount)
    }
    
    func remove(from player: Player) {
        // 즉시 효과는 제거할 것이 없음
    }
}

// 무적상태 효과
class InvincibilityEffect: ItemEffect {
    let duration: TimeInterval = GameConstants.Items.buffDuration
    let isInstant: Bool = false
    
    func apply(to player: Player) {
        player.enableInvincibility()
    }
    
    func remove(from player: Player) {
        player.disableInvincibility()
    }
}

// 샷건발사 효과
class ShotgunEffect: ItemEffect {
    let duration: TimeInterval = GameConstants.Items.buffDuration
    let isInstant: Bool = false
    
    func apply(to player: Player) {
        player.enableShotgunMode(
            bulletCount: GameConstants.Items.shotgunBulletCount,
            spreadAngle: GameConstants.Items.shotgunSpreadAngle
        )
    }
    
    func remove(from player: Player) {
        player.disableShotgunMode()
    }
}

// 메테오 효과
class MeteorEffect: ItemEffect {
    let duration: TimeInterval = GameConstants.Items.meteorDuration
    let isInstant: Bool = false
    
    func apply(to player: Player) {
        player.enableMeteorMode()
    }
    
    func remove(from player: Player) {
        player.disableMeteorMode()
    }
}
