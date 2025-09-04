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
        
        // 총알 제거 (먼저 제거해서 중복 충돌 방지)
        bullet.removeFromParent()

        if AudioManager.shared.isSoundEffectsEnabled {
            let hitSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.hit, waitForCompletion: false)
            scene.run(hitSound)
        }

        createSparkleEffect(at: bullet.position, in: scene)
        
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

        guard let impactParticle = createImpactParticle() else { return }
        impactParticle.position = position
        impactParticle.zPosition = 10
        worldNode.addChild(impactParticle)

        // Particle 효과 완료 후 자동 제거
        let waitAction = SKAction.wait(forDuration: 0.4)
        let removeAction = SKAction.removeFromParent()
        impactParticle.run(SKAction.sequence([waitAction, removeAction]))
    }

    private func createImpactParticle() -> SKEmitterNode? {
        let emitter = SKEmitterNode()

        // Spark 텍스처 설정
        let sparkTexture = SKTexture(imageNamed: ResourceConstants.Images.Effects.spark)
        emitter.particleTexture = sparkTexture

        // 기본 파티클 설정
        emitter.particleBirthRate = 300.0
        emitter.numParticlesToEmit = 25
        emitter.particleLifetime = 0.2
        emitter.particleLifetimeRange = 0.08

        // 속도와 방향
        emitter.particleSpeed = 180
        emitter.particleSpeedRange = 60
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 0.8

        // 크기와 투명도
        emitter.particleScale = 0.25
        emitter.particleScaleRange = 0.15
        emitter.particleScaleSpeed = -1.8
        emitter.particleAlpha = 0.85
        emitter.particleAlphaSpeed = -3.2

        // 네온 색상 설정
        emitter.particleColor = UIConstants.Colors.Neon.bulletSparkleColor
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil

        // 블렌드 모드
        emitter.particleBlendMode = .add

        // 물리 효과
        emitter.yAcceleration = -50
        emitter.xAcceleration = 0

        return emitter
    }
}