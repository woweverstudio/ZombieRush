//
//  PhysicsSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class PhysicsSystem: NSObject {
    
    // MARK: - Properties
    private weak var scene: SKScene?
    
    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        super.init()
        setupPhysicsContactDelegate()
    }
    
    // MARK: - Setup
    private func setupPhysicsContactDelegate() {
        scene?.physicsWorld.contactDelegate = self
    }
    
    // MARK: - Update
    func update(_ currentTime: TimeInterval) {
        // 물리 시스템 업데이트 (필요시)
    }
}

// MARK: - SKPhysicsContactDelegate
extension PhysicsSystem: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // 총알과 좀비 충돌
        if (bodyA.categoryBitMask == PhysicsCategory.bullet && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.bullet) {
            
            let bullet = bodyA.categoryBitMask == PhysicsCategory.bullet ? bodyA.node : bodyB.node
            let zombie = bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node : bodyB.node
            
            handleBulletZombieCollision(bullet: bullet, zombie: zombie)
        }
        
        // 플레이어와 좀비 충돌
        if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.player) {
            
            let player = bodyA.categoryBitMask == PhysicsCategory.player ? bodyA.node : bodyB.node
            let zombie = bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node : bodyB.node
            
            handlePlayerZombieCollision(player: player, zombie: zombie)
        }
        
        // 플레이어와 아이템 충돌
        if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.item) ||
           (bodyA.categoryBitMask == PhysicsCategory.item && bodyB.categoryBitMask == PhysicsCategory.player) {
            
            let player = bodyA.categoryBitMask == PhysicsCategory.player ? bodyA.node : bodyB.node
            let item = bodyA.categoryBitMask == PhysicsCategory.item ? bodyA.node : bodyB.node
            
            handlePlayerItemCollision(player: player, item: item)
        }
        
        // 메테오와 좀비 충돌
        if (bodyA.categoryBitMask == PhysicsCategory.meteor && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.meteor) {
            
            let meteor = bodyA.categoryBitMask == PhysicsCategory.meteor ? bodyA.node : bodyB.node
            let zombie = bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node : bodyB.node
            
            handleMeteorZombieCollision(meteor: meteor, zombie: zombie)
        }
    }
    
    private func handleBulletZombieCollision(bullet: SKNode?, zombie: SKNode?) {
        guard let bullet = bullet as? Bullet,
              let zombie = zombie as? Zombie,
              let scene = scene as? GameScene else { return }
        
        // 총알 제거
        bullet.removeFromParent()
        
        // 좀비에게 데미지
        let isDead = zombie.takeDamage(GameConstants.Bullet.damage)
        
        if isDead {
            // 점수 추가
            scene.addScore()
            
            // 좀비 스포너에서 제거
            scene.removeZombie(zombie)
        }
    }
    
    private func handlePlayerZombieCollision(player: SKNode?, zombie: SKNode?) {
        guard let player = player as? Player,
              let zombie = zombie as? Zombie,
              let scene = scene as? GameScene else { return }
        
        // 플레이어에게 데미지
        player.takeDamage(GameConstants.Player.damagePerHit)
        
        // 좀비 제거 (한 번 공격하면 사라짐)
        scene.removeZombie(zombie)
        
        // 플레이어가 죽었는지 확인
        if player.isDead() {
            // 게임 오버 처리 (나중에 구현)
            // scene.gameOver()
        }
    }
    
    private func handlePlayerItemCollision(player: SKNode?, item: SKNode?) {
        guard let item = item as? Item, let scene = scene as? GameScene else { return }
        
        // 아이템 수집 처리
        scene.collectItem(item)
    }
    
    private func handleMeteorZombieCollision(meteor: SKNode?, zombie: SKNode?) {
        guard let meteor = meteor as? Meteor,
              let zombie = zombie as? Zombie,
              let scene = scene as? GameScene else { return }
        
        // 메테오 시스템에서 충돌 처리
        scene.handleMeteorCollision(meteor: meteor, zombie: zombie)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        // Top-Down View에서는 특별한 처리 불필요
    }
}
