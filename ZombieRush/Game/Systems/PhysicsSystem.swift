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
        

    }
    
    private func handleBulletZombieCollision(bullet: SKNode?, zombie: SKNode?) {
        guard let bullet = bullet as? Bullet,
              let zombie = zombie as? Zombie,
              let scene = scene as? GameScene else { return }
        
        if AudioManager.shared.isSoundEffectsEnabled {
            let hitSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.hit, waitForCompletion: false)
            scene.run(hitSound)
        }
        
        createSparkleEffect(at: bullet.position, in: scene)
        
        // 총알 제거
        bullet.removeFromParent()
        
        // 좀비에게 데미지
        let isDead = zombie.takeDamage(GameBalance.Bullet.damage)
        
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
        player.takeDamage(GameBalance.Player.damagePerHit)
        
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
        
        if AudioManager.shared.isSoundEffectsEnabled {
            let itemSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.item, waitForCompletion: false)
            scene.run(itemSound)
        }
        
        HapticManager.shared.playItemHaptic()
        
        // 아이템 수집 처리
        scene.collectItem(item)
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
        let waitAction = SKAction.wait(forDuration: UIConstants.ParticleEffects.bulletParticleLifetime)
        let removeAction = SKAction.removeFromParent()
        impactParticle.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func createImpactParticle() -> SKEmitterNode? {
        guard let emitter = SKEmitterNode(fileNamed: ResourceConstants.ParticleEffects.bulletImpact) else { return nil }
        
        // 기본 파티클 설정 (네온 사이버펑크 스타일)
        emitter.particleBirthRate = UIConstants.ParticleEffects.bulletParticleBirthRate
        emitter.numParticlesToEmit = UIConstants.ParticleEffects.bulletParticleCount
        emitter.particleLifetime = UIConstants.ParticleEffects.bulletParticleLifetimeBase
        emitter.particleLifetimeRange = UIConstants.ParticleEffects.bulletParticleLifetimeRange
        
        // 속도와 방향
        emitter.particleSpeed = UIConstants.ParticleEffects.bulletParticleSpeed
        emitter.particleSpeedRange = UIConstants.ParticleEffects.bulletParticleSpeedRange
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2 // 360도
        
        // 크기와 투명도
        emitter.particleScale = UIConstants.ParticleEffects.bulletParticleScale
        emitter.particleScaleRange = UIConstants.ParticleEffects.bulletParticleScaleRange
        emitter.particleScaleSpeed = UIConstants.ParticleEffects.bulletParticleScaleSpeed
        emitter.particleAlpha = UIConstants.ParticleEffects.bulletParticleAlpha
        emitter.particleAlphaSpeed = UIConstants.ParticleEffects.bulletParticleAlphaSpeed
        
        // 네온 색상 설정
        emitter.particleColor = UIConstants.Colors.Neon.bulletSparkleColor
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