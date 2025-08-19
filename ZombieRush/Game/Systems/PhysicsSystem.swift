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
        
        // 타격 사운드 재생 (SpriteKit 방식)
        if AudioManager.shared.isSoundEffectsEnabled {
            let hitSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.hit, waitForCompletion: false)
            scene.run(hitSound)
        }
        
        // 스파클 효과 생성 (총알 위치에서)
        createSparkleEffect(at: bullet.position, in: scene)
        
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
        
        // 아이템 수집 사운드 재생 (SpriteKit 방식)
        if AudioManager.shared.isSoundEffectsEnabled {
            let itemSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.item, waitForCompletion: false)
            scene.run(itemSound)
        }
        
        // 아이템 수집 햅틱 피드백
        HapticManager.shared.playItemHaptic()
        
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
    
    // MARK: - Visual Effects
    private func createSparkleEffect(at position: CGPoint, in scene: SKScene) {
        guard let worldNode = scene.childNode(withName: "World") else { return }
        
        // 코드로 파티클 이펙트 생성 (네온 사이버펑크 스타일)
        guard let impactParticle = createImpactParticle() else { return }
        
        impactParticle.position = position
        impactParticle.zPosition = 10
        
        worldNode.addChild(impactParticle)
        
        // 파티클 효과 완료 후 자동 제거
        let waitAction = SKAction.wait(forDuration: GameConstants.Bullet.particleLifetime)
        let removeAction = SKAction.removeFromParent()
        impactParticle.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func createImpactParticle() -> SKEmitterNode? {
        guard let emitter = SKEmitterNode(fileNamed: "BulletImpact") else { return nil }
        
        // 기본 파티클 설정 (네온 사이버펑크 스타일)
        emitter.particleBirthRate = GameConstants.Bullet.particleBirthRate
        emitter.numParticlesToEmit = GameConstants.Bullet.particleCount
        emitter.particleLifetime = GameConstants.Bullet.particleLifetimeBase
        emitter.particleLifetimeRange = GameConstants.Bullet.particleLifetimeRange
        
        // 속도와 방향
        emitter.particleSpeed = GameConstants.Bullet.particleSpeed
        emitter.particleSpeedRange = GameConstants.Bullet.particleSpeedRange
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2 // 360도
        
        // 크기와 투명도
        emitter.particleScale = GameConstants.Bullet.particleScale
        emitter.particleScaleRange = GameConstants.Bullet.particleScaleRange
        emitter.particleScaleSpeed = GameConstants.Bullet.particleScaleSpeed
        emitter.particleAlpha = GameConstants.Bullet.particleAlpha
        emitter.particleAlphaSpeed = GameConstants.Bullet.particleAlphaSpeed
        
        // 네온 색상 설정
        emitter.particleColor = GameConstants.Bullet.sparkleColor
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil
        
        // 블렌드 모드 (네온 효과의 핵심)
        emitter.particleBlendMode = .add
        
        // 물리 효과 (탑다운이므로 중력 없음)
        emitter.yAcceleration = 0
        emitter.xAcceleration = 0
        
        return emitter
    }
}