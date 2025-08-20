//
//  Player.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    
    // MARK: - Properties
    
    // 이미지 관련 프로퍼티 제거됨 - 단순한 원형 사용
    private var lastMoveDirection: CGVector = CGVector.zero
    
    // MARK: - Face Expression Properties
    private var faceExpressionNode: SKSpriteNode?
    
    // MARK: - Movement Properties
    private var baseMoveSpeed: CGFloat = GameConstants.Player.baseMoveSpeed
    private var currentMoveSpeed: CGFloat = GameConstants.Player.baseMoveSpeed
    private var speedBoostActive: Bool = false
    
    // MARK: - Player Stats
    private var maxHealth: Int = GameConstants.Player.maxHealth
    private var currentHealth: Int = GameConstants.Player.maxHealth
    private var maxAmmo: Int = GameConstants.Player.maxAmmo
    private var currentAmmo: Int = GameConstants.Player.maxAmmo
    private var reloadTime: TimeInterval = GameConstants.Player.reloadTime
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
        super.init(texture: nil, color: .clear, size: GameConstants.Player.size)
        
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
        physicsBody?.linearDamping = GameConstants.Physics.playerLinearDamping // 부드러운 정지 (속도 저하 최소화)
        
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
        // 둥근 사각형으로 변경 (좀비와 통일)
        let rect = CGRect(
            x: -size.width/2, 
            y: -size.height/2, 
            width: size.width, 
            height: size.height
        )
        let neonRect = SKShapeNode(rect: rect, cornerRadius: 4)
        neonRect.fillColor = GameConstants.NeonEffects.playerNeonColor
        neonRect.strokeColor = GameConstants.NeonEffects.playerNeonColor
        neonRect.lineWidth = 2
        neonRect.glowWidth = GameConstants.NeonEffects.playerGlowWidth
        neonRect.position = CGPoint.zero
        neonRect.name = "PlayerShape"
        
        addChild(neonRect)
        
        // 표정 레이어 추가
        setupFaceExpression()
    }
    
    // MARK: - Face Expression Setup
    private func setupFaceExpression() {
        let faceTexture = SKTexture(imageNamed: "face_normal")
        
        faceExpressionNode = SKSpriteNode(texture: faceTexture)
        faceExpressionNode?.size = CGSize(width: size.width , height: size.height)
        faceExpressionNode?.position = CGPoint.zero
        faceExpressionNode?.zPosition = 1 // 네온 사각형 위에 표시
        faceExpressionNode?.name = "FaceExpression"
        
        if let faceNode = faceExpressionNode {
            addChild(faceNode)
        }
    }
    
    // MARK: - Movement Methods
    func move(direction: CGVector) {
        // 이동 방향 저장
        lastMoveDirection = direction
        
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
        lastMoveDirection = CGVector.zero
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
            let reloadSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.reload, waitForCompletion: false)
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
    
    func takeDamage(_ damage: Int = GameConstants.Player.damagePerHit) {
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
    func getHealth() -> Int { return currentHealth }
    func getMaxHealth() -> Int { return maxHealth }
    func getAmmo() -> Int { return currentAmmo }
    func getMaxAmmo() -> Int { return maxAmmo }
    func getIsReloading() -> Bool { return isReloading }
    func isDead() -> Bool { return currentHealth <= 0 }
    func getIsInvincible() -> Bool { return isInvincible }
    func getIsShotgunMode() -> Bool { return shotgunModeActive }
    func getShotgunBulletCount() -> Int { return shotgunBulletCount }
    func getShotgunSpreadAngle() -> CGFloat { return shotgunSpreadAngle }

    
    // Fire Direction Tracking 메서드들 제거됨 - 단순한 원형 사용
    
    // MARK: - Item Effects
    func applySpeedBoost(multiplier: CGFloat) {
        speedBoostActive = true
        currentMoveSpeed = baseMoveSpeed * multiplier
        
        // 시각적 효과 (속도 부스트 - 빠른 펄스 효과)
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
        
        // 회복 효과가 있었을 때만 시각적 효과 (이미지와 호환되는 방식)
        if currentHealth > oldHealth {
            // 스케일 효과로 대체
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
        
        // 탄약 충전 효과 (이미지와 호환되는 방식)
        let ammoEffect = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(ammoEffect)
    }
    
    func enableInvincibility() {
        isInvincible = true
        
        // 무적 상태 시각적 효과 (깜빡임)
        let blinkAction = AnimationUtils.createBlinkEffect(minAlpha: 0.5, maxAlpha: 1.0, duration: 0.2)
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
        
        // 샷건 모드 시각적 효과 (강한 펄스 + 회전 효과)
        let shotgunEffect = SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.15, duration: 0.3)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
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
    
    // MARK: - Face Expression Methods
    func changeFaceExpression(to imageName: String) {
        guard let faceNode = faceExpressionNode else {
            print("Warning: Face expression node not found")
            return
        }
        
        let newTexture = SKTexture(imageNamed: imageName)
        
        // 부드러운 전환 효과
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        let changeTexture = SKAction.run {
            faceNode.texture = newTexture
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        
        let transitionSequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])
        faceNode.run(transitionSequence)
    }
    
    func setNormalFace() {
        changeFaceExpression(to: "face_normal")
    }
    
    func temporaryFaceExpression(imageName: String, duration: TimeInterval = 1.0) {
        changeFaceExpression(to: imageName)
        
        // 일정 시간 후 기본 표정으로 복원
        let waitAction = SKAction.wait(forDuration: duration)
        let restoreAction = SKAction.run { [weak self] in
            self?.setNormalFace()
        }
        
        let sequence = SKAction.sequence([waitAction, restoreAction])
        run(sequence, withKey: "temporaryFaceExpression")
    }
    
    // MARK: - Wave Speed Bonus
    func updateWaveSpeed(currentWave: Int) {
        let waveBonus = min(
            CGFloat(currentWave - 1) * GameConstants.Player.waveSpeedBonus,
            GameConstants.Player.maxWaveSpeedBonus
        )
        
        baseMoveSpeed = GameConstants.Player.baseMoveSpeed + waveBonus
        
        // 현재 속도도 업데이트 (아이템 효과 고려)
        if speedBoostActive {
            currentMoveSpeed = baseMoveSpeed * GameConstants.Items.speedMultiplier
        } else {
            currentMoveSpeed = baseMoveSpeed
        }
    }
}
