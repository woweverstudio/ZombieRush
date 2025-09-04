//
//  Player.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    // MARK: - Face Expression Properties
    private var faceExpressionNode: SKSpriteNode?
    
    // MARK: - Movement Properties
    private var baseMoveSpeed: CGFloat = GameBalance.Player.baseMoveSpeed
    private var currentMoveSpeed: CGFloat = GameBalance.Player.baseMoveSpeed
    private var speedBoostActive: Bool = false
    
    // MARK: - Player Stats
    private var maxHealth: Int = GameBalance.Player.maxHealth
    private var currentHealth: Int = GameBalance.Player.maxHealth
    private var maxAmmo: Int = GameBalance.Player.maxAmmo
    private var currentAmmo: Int = GameBalance.Player.maxAmmo
    private var reloadTime: TimeInterval = GameBalance.Player.reloadTime
    private var isReloading: Bool = false
    
    // MARK: - Item Effects
    private var isInvincible: Bool = false
    private var shotgunModeActive: Bool = false
    private var shotgunBulletCount: Int = 1
    private var shotgunSpreadAngle: CGFloat = 0
    
    // MARK: - System References
    private weak var meteorSystem: MeteorSystem?
    
    // MARK: - Initialization
    init() {
        // 원형 플레이어로 초기화 (SKShapeNode 사용)
        super.init(texture: nil, color: .clear, size: GameBalance.Player.size)
        
        setupPhysics()
        setupProperties()
        setupNeonCircle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false  // 회전 완전 차단
        physicsBody?.mass = 1.0
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.0
        physicsBody?.linearDamping = GameBalance.Physics.playerLinearDamping // 부드러운 정지 (속도 저하 최소화)
        
        // 물리 카테고리 설정
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.worldBorder // 맵 경계와 충돌
    }
    
    private func setupProperties() {
        name = "Player"
        zPosition = 10
    }
    
    // MARK: - Neon Rectangle Setup
    private func setupNeonCircle() {
        let rect = CGRect(
            x: -size.width/2,
            y: -size.height/2,
            width: size.width,
            height: size.height
        )
        let neonRect = SKShapeNode(rect: rect, cornerRadius: 4)
        neonRect.fillColor = UIConstants.Colors.Neon.playerColor
        neonRect.strokeColor = UIConstants.Colors.Neon.playerColor
        neonRect.lineWidth = 2
        neonRect.position = .zero
        neonRect.name = "PlayerShape"
        
        addChild(neonRect)
        setupFaceExpressions()
    }
    
    private func setupFaceExpressions() {
        let normalTexture = SKTexture(imageNamed: "face_normal")
        faceExpressionNode = SKSpriteNode(texture: normalTexture)
        faceExpressionNode?.size = size
        faceExpressionNode?.position = .zero
        faceExpressionNode?.zPosition = 1
        faceExpressionNode?.name = "FaceExpression"
        
        if let faceNode = faceExpressionNode {
            addChild(faceNode)
        }
    }
    
    // MARK: - Movement Methods
    func move(direction: CGVector) {
        // 방향 벡터 정규화 (360도 지원)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        if length > 0 {
            let normalizedDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
            
            // 속도 설정 (현재 이동속도 사용)
            let velocity = CGVector(
                dx: normalizedDirection.dx * currentMoveSpeed,
                dy: normalizedDirection.dy * currentMoveSpeed
            )
            
            physicsBody?.velocity = velocity
        } else {
            stopMoving()
        }
    }
    
    func stopMoving() {
        physicsBody?.velocity = CGVector.zero
    }
    
    // MARK: - Combat Methods
    func canFire() -> Bool {
        return currentAmmo > 0 && !isReloading
    }
    
    func consumeAmmo() {
        if currentAmmo > 0 {
            currentAmmo -= 1
            
            // 탄약이 떨어지면 자동 재장전
            if currentAmmo == 0 {
                startReload()
            }
        }
    }
    
    func startReload() {
        guard !isReloading && currentAmmo < maxAmmo else { return }
        
        isReloading = true
        
        if AudioManager.shared.isSoundEffectsEnabled {
            let reloadSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.reload, waitForCompletion: false)
            run(reloadSound)
        }
        
        let reloadAction = SKAction.sequence([
            SKAction.wait(forDuration: reloadTime),
            SKAction.run { [weak self] in
                self?.finishReload()
            }
        ])
        
        run(reloadAction, withKey: "reload")
    }
    
    private func finishReload() {
        currentAmmo = maxAmmo
        isReloading = false
    }
    
    func takeDamage(_ damage: Int = GameBalance.Player.damagePerHit) {
        // 무적 상태에서는 데미지를 받지 않음
        if isInvincible {
            return
        }
        
        currentHealth = max(0, currentHealth - damage)
        
        HapticManager.shared.playHitHaptic()
        
        let flashAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])
        run(flashAction)
        
        // 데미지를 받을 때 face_hit 표정으로 1초간 변경 후 normal로 복원
        temporaryFaceExpression(imageName: "face_hit", duration: 1.0)
    }
    
    func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }
    
    // MARK: - Getters
    func getHealth() -> Int { currentHealth }
    func getMaxHealth() -> Int { maxHealth }
    func getAmmo() -> Int { currentAmmo }
    func getMaxAmmo() -> Int { maxAmmo }
    func getIsReloading() -> Bool { isReloading }
    func isDead() -> Bool { currentHealth <= 0 }
    func getIsInvincible() -> Bool { isInvincible }
    func getIsShotgunMode() -> Bool { shotgunModeActive }
    func getShotgunBulletCount() -> Int { shotgunBulletCount }
    func getShotgunSpreadAngle() -> CGFloat { shotgunSpreadAngle }
    
    // MARK: - Item Effects
    func applySpeedBoost(multiplier: CGFloat) {
        speedBoostActive = true
        currentMoveSpeed = baseMoveSpeed * multiplier
        
        let speedEffect = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
        run(speedEffect, withKey: "speedBoostEffect")
    }
    
    func removeSpeedBoost() {
        speedBoostActive = false
        currentMoveSpeed = baseMoveSpeed  // 웨이브 보너스가 적용된 baseMoveSpeed 사용
        removeAction(forKey: "speedBoostEffect")
    }
    
    func restoreHealth(amount: Int) {
        let oldHealth = currentHealth
        currentHealth = min(maxHealth, currentHealth + amount)
        
        if currentHealth > oldHealth {
            let healEffect = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            run(healEffect)
        }
    }
    
    func restoreAmmo(amount: Int) {
        currentAmmo = min(maxAmmo, currentAmmo + amount)
        
        // 재장전 중이었다면 취소
        if isReloading {
            isReloading = false
            removeAction(forKey: "reload")
        }
        
        let ammoEffect = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(ammoEffect)
    }
    
    func enableInvincibility() {
        isInvincible = true
        
        // 무적 상태 시각적 효과 (깜빡임)
        let blinkAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ]))
        run(blinkAction, withKey: "invincibilityEffect")
    }
    
    func disableInvincibility() {
        isInvincible = false
        removeAction(forKey: "invincibilityEffect")
        alpha = 1.0  // 투명도 원상복구
    }
    
    func enableShotgunMode(bulletCount: Int, spreadAngle: CGFloat) {
        shotgunModeActive = true
        shotgunBulletCount = bulletCount
        shotgunSpreadAngle = spreadAngle
        
        let shotgunEffect = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        run(shotgunEffect, withKey: "shotgunEffect")
    }
    
    func disableShotgunMode() {
        shotgunModeActive = false
        shotgunBulletCount = 1
        shotgunSpreadAngle = 0
        removeAction(forKey: "shotgunEffect")
    }
    
    func deployMeteor() {
        // 메테오 시스템을 통해 현재 위치에 폭탄 설치
        meteorSystem?.deployMeteor(at: position)
    }
    
    func setMeteorSystem(_ meteorSystem: MeteorSystem) {
        self.meteorSystem = meteorSystem
    }
    
    func changeFaceExpression(to imageName: String) {
        guard let faceNode = faceExpressionNode else { return }
        
        let texture = SKTexture(imageNamed: imageName)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        let changeTexture = SKAction.run { faceNode.texture = texture }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        
        let sequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])
        faceNode.run(sequence)
    }
    
    func setNormalFace() {
        changeFaceExpression(to: "face_normal")
    }
    
    func temporaryFaceExpression(imageName: String, duration: TimeInterval = 1.0) {
        changeFaceExpression(to: imageName)
        
        let waitAction = SKAction.wait(forDuration: duration)
        let restoreAction = SKAction.run { [weak self] in
            self?.setNormalFace()
        }
        
        let sequence = SKAction.sequence([waitAction, restoreAction])
        run(sequence, withKey: "temporaryFaceExpression")
    }
    
    func updateWaveSpeed(currentWave: Int) {
        let waveBonus = min(
            CGFloat(currentWave - 1) * GameBalance.Player.waveSpeedBonus,
            GameBalance.Player.maxWaveSpeedBonus
        )
        
        baseMoveSpeed = GameBalance.Player.baseMoveSpeed + waveBonus
        
        if speedBoostActive {
            currentMoveSpeed = baseMoveSpeed * GameBalance.Items.speedMultiplier
        } else {
            currentMoveSpeed = baseMoveSpeed
        }
    }
}
