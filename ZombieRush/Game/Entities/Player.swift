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
    
    // MARK: - Image Properties
    private var currentDirection: GameConstants.Player.PlayerDirection = GameConstants.Player.defaultDirection
    private var lastMoveDirection: CGVector = CGVector.zero
    private var lastFireDirection: CGVector = CGVector.zero
    private var isFiring: Bool = false
    
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
        // 텍스처 캐시를 사용한 기본 이미지 초기화
        let defaultTexture = TextureCache.shared.getTexture(named: GameConstants.Player.defaultDirection.imageName) ?? SKTexture()
        let size = GameConstants.Player.size
        super.init(texture: defaultTexture, color: .clear, size: size)
        
        setupPhysics()
        setupProperties()
        setupImageSystem()
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
    
    private func setupImageSystem() {
        // 원본 비율 유지하면서 크기 조정
        maintainAspectRatio()
    }
    
    // MARK: - Image Management
    private func maintainAspectRatio() {
        guard let texture = texture else { return }
        let originalSize = texture.size()
        let targetSize = GameConstants.Player.size
        
        // 원본 비율을 유지하면서 targetSize에 맞춤 (aspect fit)
        let scaleX = targetSize.width / originalSize.width
        let scaleY = targetSize.height / originalSize.height
        let scale = min(scaleX, scaleY)
        
        size = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
    }
    
    private func updatePlayerImage() {
        let newDirection = determineDirection()
        
        if newDirection != currentDirection {
            currentDirection = newDirection
            
            // 텍스처 캐시를 사용한 최적화된 이미지 로딩
            if let cachedTexture = TextureCache.shared.getTexture(named: currentDirection.imageName) {
                texture = cachedTexture
                maintainAspectRatio()
            }
        }
    }
    
    private func determineDirection() -> GameConstants.Player.PlayerDirection {
        // 우선순위: 발사 방향 > 이동 방향 > 기본 방향
        let directionVector: CGVector
        
        if isFiring && lastFireDirection != CGVector.zero {
            directionVector = lastFireDirection
        } else if lastMoveDirection != CGVector.zero {
            directionVector = lastMoveDirection
        } else {
            return currentDirection // 변화 없음
        }
        
        // 각도 계산 (라디안)
        let angle = atan2(directionVector.dy, directionVector.dx)
        let degrees = angle * 180 / .pi
        
        // 각도를 0-360도로 정규화
        let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
        
        // 좌우 판단: 우측(270-90도), 좌측(90-270도)
        // 수직일 때는 기본값(왼쪽) 사용
        if normalizedDegrees > 270 || normalizedDegrees < 90 {
            return .right
        } else {
            return .left
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
            
            // 이미지 업데이트
            updatePlayerImage()
        } else {
            stopMoving()
        }
    }
    
    func stopMoving() {
        physicsBody?.velocity = CGVector.zero
        lastMoveDirection = CGVector.zero
        isFiring = false
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
        
        // 피격 효과 (이미지와 호환되는 방식)
        let flashAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])
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
    
    // MARK: - Fire Direction Tracking
    func setFireDirection(_ direction: CGVector) {
        lastFireDirection = direction
        isFiring = true
        updatePlayerImage()
    }
    
    func stopFiring() {
        isFiring = false
        updatePlayerImage()
    }
    
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
                SKAction.scale(to: 1.15, duration: 0.3),
                SKAction.rotate(byAngle: .pi / 8, duration: 0.3)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.rotate(byAngle: -.pi / 8, duration: 0.3)
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
    
    func enableMeteorMode() {
        meteorModeActive = true
        
        // 메테오 모드 시각적 효과 (신비로운 떨림 + 스케일 효과)
        let meteorEffect = SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.1, duration: 0.4),
                SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.4),
                SKAction.fadeAlpha(to: 1.0, duration: 0.4)
            ])
        ]))
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
