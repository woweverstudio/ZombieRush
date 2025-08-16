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
    private var meteorModeActive: Bool = false
    
    // MARK: - Initialization
    init() {
        // 이미지가 없으므로 간단한 원형 노드로 생성
        let size = GameConstants.Player.size
        super.init(texture: nil, color: .blue, size: size)
        
        setupPhysics()
        setupProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
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
        
        // 피격 효과
        let flashAction = AnimationUtils.createFlashEffect(flashColor: .red, originalColor: .blue, duration: 0.1)
        run(flashAction)
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
    func getIsMeteorMode() -> Bool { return meteorModeActive }
    
    // MARK: - Item Effects
    func applySpeedBoost(multiplier: CGFloat) {
        speedBoostActive = true
        currentMoveSpeed = baseMoveSpeed * multiplier
        
        // 시각적 효과 (파란색 글로우)
        let glowAction = AnimationUtils.createGlowEffect(primaryColor: .cyan, secondaryColor: .blue, duration: 0.5)
        run(glowAction, withKey: "speedBoostEffect")
    }
    
    func removeSpeedBoost() {
        speedBoostActive = false
        currentMoveSpeed = baseMoveSpeed  // 웨이브 보너스가 적용된 baseMoveSpeed 사용
        removeAction(forKey: "speedBoostEffect")
    }
    
    func restoreHealth(amount: Int) {
        let oldHealth = currentHealth
        currentHealth = min(maxHealth, currentHealth + amount)
        
        // 회복 효과가 있었을 때만 시각적 효과
        if currentHealth > oldHealth {
            let healEffect = SKAction.sequence([
                SKAction.colorize(with: .green, colorBlendFactor: 0.5, duration: 0.2),
                SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.2)
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
        
        // 탄약 충전 효과
        let ammoEffect = SKAction.sequence([
            SKAction.colorize(with: .blue, colorBlendFactor: 0.5, duration: 0.2),
            SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.2)
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
        
        // 샷건 모드 시각적 효과 (주황색 글로우)
        let shotgunEffect = AnimationUtils.createGlowEffect(primaryColor: .orange, secondaryColor: .blue, duration: 0.3)
        run(shotgunEffect, withKey: "shotgunEffect")
    }
    
    func disableShotgunMode() {
        shotgunModeActive = false
        shotgunBulletCount = 1
        shotgunSpreadAngle = 0
        removeAction(forKey: "shotgunEffect")
    }
    
    func enableMeteorMode() {
        meteorModeActive = true
        
        // 메테오 모드 시각적 효과 (보라색 글로우)
        let meteorEffect = AnimationUtils.createGlowEffect(primaryColor: .purple, secondaryColor: .blue, duration: 0.4)
        run(meteorEffect, withKey: "meteorEffect")
    }
    
    func disableMeteorMode() {
        meteorModeActive = false
        removeAction(forKey: "meteorEffect")
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
