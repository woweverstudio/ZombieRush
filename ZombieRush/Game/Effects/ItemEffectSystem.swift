import Foundation
import SpriteKit

class ItemEffectSystem {
    
    // MARK: - Properties
    private weak var player: Player?
    private weak var toastMessageManager: ToastMessageManager?
    
    // 활성 효과 추적
    private var activeEffects: [ItemType: Timer] = [:]
    
    // MARK: - Initialization
    init(player: Player, toastMessageManager: ToastMessageManager) {
        self.player = player
        self.toastMessageManager = toastMessageManager
    }
    
    // MARK: - Public Methods
    func applyItemEffect(type: ItemType) {
        guard let player = player else { return }
        
        let effect = ItemEffectFactory.createEffect(for: type)
        
        // 효과 적용
        effect.apply(to: player)
        
        // 토스트 메시지 표시
        showItemCollectedMessage(type: type)
        
        // 즉시 효과가 아닌 경우 지속시간 관리
        if !effect.isInstant {
            startEffectTimer(type: type, effect: effect)
        }
    }
    
    func removeAllEffects() {
        guard let player = player else { return }
        
        // 모든 활성 효과 제거
        for (type, timer) in activeEffects {
            timer.invalidate()
            let effect = ItemEffectFactory.createEffect(for: type)
            effect.remove(from: player)
        }
        
        activeEffects.removeAll()
    }
    
    func getActiveEffects() -> [ItemType] {
        return Array(activeEffects.keys)
    }
    
    func isEffectActive(_ type: ItemType) -> Bool {
        return activeEffects[type] != nil
    }
    
    // MARK: - Private Methods
    private func startEffectTimer(type: ItemType, effect: ItemEffect) {
        // 기존 동일 효과가 있다면 제거 (효과 갱신)
        if let existingTimer = activeEffects[type] {
            existingTimer.invalidate()
        }
        
        // 새 타이머 시작
        let timer = Timer.scheduledTimer(withTimeInterval: effect.duration, repeats: false) { [weak self] _ in
            self?.removeEffect(type: type, effect: effect)
        }
        
        activeEffects[type] = timer
    }
    
    private func removeEffect(type: ItemType, effect: ItemEffect) {
        guard let player = player else { return }
        
        // 효과 제거
        effect.remove(from: player)
        
        // 타이머 제거
        activeEffects.removeValue(forKey: type)
        
        // 효과 종료 메시지
        showEffectEndedMessage(type: type)
    }
    
    private func showItemCollectedMessage(type: ItemType) {
        let message: String
        
        switch type {
        case .speedBoost:
            message = NSLocalizedString("ITEM_SPEED_BOOST_COLLECT", comment: "Speed boost item collected")
        case .healthRestore:
            message = NSLocalizedString("ITEM_HEALTH_RESTORE_COLLECT", comment: "Health restore item collected")
        case .ammoRestore:
            message = NSLocalizedString("ITEM_AMMO_RESTORE_COLLECT", comment: "Ammo restore item collected")
        case .invincibility:
            message = NSLocalizedString("ITEM_INVINCIBILITY_COLLECT", comment: "Invincibility item collected")
        case .shotgun:
            message = NSLocalizedString("ITEM_SHOTGUN_COLLECT", comment: "Shotgun item collected")
        case .meteor:
            message = NSLocalizedString("ITEM_METEOR_COLLECT", comment: "Meteor item collected")
        }
        
        toastMessageManager?.showToastMessage(message, duration: 1.5)
    }
    
    private func showEffectEndedMessage(type: ItemType) {
        // 즉시 효과는 종료 메시지가 없음
        guard !type.isInstantEffect else { return }
        
        let message: String
        
        switch type {
        case .speedBoost:
            message = NSLocalizedString("ITEM_SPEED_BOOST_END", comment: "Speed boost effect ended")
        case .invincibility:
            message = NSLocalizedString("ITEM_INVINCIBILITY_END", comment: "Invincibility effect ended")
        case .shotgun:
            message = NSLocalizedString("ITEM_SHOTGUN_END", comment: "Shotgun effect ended")
        case .meteor:
            return
        default:
            return  // 즉시 효과는 메시지 없음
        }
        
        toastMessageManager?.showToastMessage(message, duration: 1.0)
    }
    
    // MARK: - Cleanup
    deinit {
        removeAllEffects()
    }
}
