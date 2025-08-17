//
//  Zombie.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

enum ZombieType {
    case normal
    case fast
    case strong
}

class Zombie: SKSpriteNode {
    
    // MARK: - Properties
    private let zombieType: ZombieType
    private let moveSpeed: CGFloat
    private let health: Int
    private var currentHealth: Int
    
    private weak var target: SKNode?
    
    // MARK: - Image Properties
    private var currentDirection: GameConstants.Zombie.ZombieDirection = .left
    private var lastMoveDirection: CGVector = CGVector.zero
    
    // MARK: - Performance Optimization
    private var directionUpdateThreshold: CGFloat = 0.1 // 방향 변경 최소 임계값
    private var lastDirectionUpdate: TimeInterval = 0
    private let directionUpdateInterval: TimeInterval = 0.1 // 방향 업데이트 간격 (100ms)
    
    // MARK: - Initialization
    init(type: ZombieType) {
        self.zombieType = type
        
        // 웨이브별 배수 적용
        let speedMultiplier = GameStateManager.shared.getZombieSpeedMultiplier()
        let healthMultiplier = GameStateManager.shared.getZombieHealthMultiplier()
        
        // 타입별 속성 설정
        let size: CGSize
        let defaultImageName: String
        
        switch type {
        case .normal:
            self.moveSpeed = GameConstants.Zombie.normalSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.normalHealth) * healthMultiplier)
            size = GameConstants.Zombie.normalSize
            defaultImageName = GameConstants.Zombie.normalLeftImage
            
        case .fast:
            self.moveSpeed = GameConstants.Zombie.fastSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.fastHealth) * healthMultiplier)
            size = GameConstants.Zombie.fastSize
            defaultImageName = GameConstants.Zombie.fastLeftImage
            
        case .strong:
            self.moveSpeed = GameConstants.Zombie.strongSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.strongHealth) * healthMultiplier)
            size = GameConstants.Zombie.strongSize
            defaultImageName = GameConstants.Zombie.strongLeftImage
        }
        
        self.currentHealth = health
        
        // 텍스처 캐시를 사용한 안전한 이미지 로딩
        if let defaultTexture = TextureCache.shared.getTexture(named: defaultImageName) {
            super.init(texture: defaultTexture, color: .clear, size: size)
        } else {
            // 이미지가 없을 경우 기본 색상으로 초기화 (폴백)
            let fallbackColor: SKColor
            switch type {
            case .normal: fallbackColor = .green
            case .fast: fallbackColor = .yellow
            case .strong: fallbackColor = .red
            }
            super.init(texture: nil, color: fallbackColor, size: size)
            print("⚠️ 좀비 이미지 없음, 기본 색상 사용: \(defaultImageName)")
        }
        
        setupZombie()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupZombie() {
        name = GameConstants.NodeNames.zombie
        zPosition = 8
        
        // 물리 설정
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.worldBorder
        physicsBody?.linearDamping = GameConstants.Physics.zombieLinearDamping
        
        // 이미지 시스템 설정
        setupImageSystem()
    }
    
    // MARK: - Image Management
    private func setupImageSystem() {
        maintainAspectRatio()
    }
    
    private func maintainAspectRatio() {
        guard let texture = texture else { return }
        let originalSize = texture.size()
        let targetSize = getTargetSize()
        
        // 원본 비율을 유지하면서 targetSize에 맞춤 (aspect fit)
        let scaleX = targetSize.width / originalSize.width
        let scaleY = targetSize.height / originalSize.height
        let scale = min(scaleX, scaleY)
        
        size = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
    }
    
    private func getTargetSize() -> CGSize {
        switch zombieType {
        case .normal:
            return GameConstants.Zombie.normalSize
        case .fast:
            return GameConstants.Zombie.fastSize
        case .strong:
            return GameConstants.Zombie.strongSize
        }
    }
    
    private func updateZombieImage() {
        let newDirection = determineDirection()
        
        if newDirection != currentDirection {
            currentDirection = newDirection
            
            let imageName = getImageName(for: newDirection)
            
            // 텍스처 캐시를 사용한 최적화된 이미지 로딩
            if let cachedTexture = TextureCache.shared.getTexture(named: imageName) {
                texture = cachedTexture
                maintainAspectRatio()
            } else {
                // 이미지 로딩 실패 시 기본 색상으로 대체
                texture = nil
                color = getFallbackColor()
                print("⚠️ 좀비 이미지 로딩 실패: \(imageName)")
            }
        }
    }
    
    private func determineDirection() -> GameConstants.Zombie.ZombieDirection {
        guard lastMoveDirection != CGVector.zero else {
            return currentDirection // 움직이지 않으면 현재 방향 유지
        }
        
        // 각도 계산 (라디안)
        let angle = atan2(lastMoveDirection.dy, lastMoveDirection.dx)
        let degrees = angle * 180 / .pi
        
        // 각도를 0-360도로 정규화
        let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
        
        // 좌우 판단: 우측(270-90도), 좌측(90-270도)
        if normalizedDegrees > 270 || normalizedDegrees < 90 {
            return .right
        } else {
            return .left
        }
    }
    
    private func getImageName(for direction: GameConstants.Zombie.ZombieDirection) -> String {
        switch zombieType {
        case .normal:
            return direction == .left ? GameConstants.Zombie.normalLeftImage : GameConstants.Zombie.normalRightImage
        case .fast:
            return direction == .left ? GameConstants.Zombie.fastLeftImage : GameConstants.Zombie.fastRightImage
        case .strong:
            return direction == .left ? GameConstants.Zombie.strongLeftImage : GameConstants.Zombie.strongRightImage
        }
    }
    
    private func getFallbackColor() -> SKColor {
        switch zombieType {
        case .normal: return .green
        case .fast: return .yellow
        case .strong: return .red
        }
    }
    
    // MARK: - Hit Effects
    private func showHitMessage() {
        // "Hit" 토스트 메시지 생성
        let hitLabel = SKLabelNode(text: "Hit")
        hitLabel.fontName = "Arial-Bold"
        hitLabel.fontSize = 16
        hitLabel.fontColor = .red
        hitLabel.position = CGPoint(x: 0, y: size.height / 2 + 15) // 좀비 머리 위
        hitLabel.zPosition = 100
        
        // 그림자 효과
        let shadowLabel = SKLabelNode(text: "Hit")
        shadowLabel.fontName = "Arial-Bold"
        shadowLabel.fontSize = 16
        shadowLabel.fontColor = .black
        shadowLabel.alpha = 0.5
        shadowLabel.position = CGPoint(x: 1, y: -1) // 그림자 오프셋
        shadowLabel.zPosition = 99
        hitLabel.addChild(shadowLabel)
        
        addChild(hitLabel)
        
        // 애니메이션 효과
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let remove = SKAction.removeFromParent()
        
        let scaleEffect = SKAction.sequence([scaleUp, scaleDown])
        let disappearEffect = SKAction.group([moveUp, fadeOut])
        let fullAnimation = SKAction.sequence([scaleEffect, disappearEffect, remove])
        
        hitLabel.run(fullAnimation)
    }
    
    // MARK: - AI Methods
    func setTarget(_ target: SKNode) {
        self.target = target
    }
    
    func update() {
        guard let target = target else { return }
        
        // 플레이어 방향으로 이동
        let deltaX = target.position.x - position.x
        let deltaY = target.position.y - position.y
        let distance = hypot(deltaX, deltaY)
        
        if distance > 0 {
            let normalizedX = deltaX / distance
            let normalizedY = deltaY / distance
            
            let velocity = CGVector(
                dx: normalizedX * moveSpeed,
                dy: normalizedY * moveSpeed
            )
            
            // 이동 방향 저장 (이미지 업데이트용)
            lastMoveDirection = velocity
            
            physicsBody?.velocity = velocity
            
            // 성능 최적화: 이미지 업데이트 빈도 제한
            updateZombieImageOptimized()
        } else {
            // 정지 상태
            lastMoveDirection = CGVector.zero
        }
    }
    
    // MARK: - Optimized Image Update
    private func updateZombieImageOptimized() {
        let currentTime = CACurrentMediaTime()
        
        // 방향 업데이트 간격 체크 (성능 최적화)
        guard currentTime - lastDirectionUpdate >= directionUpdateInterval else { return }
        
        let newDirection = determineDirection()
        
        // 방향이 실제로 변경되었을 때만 업데이트
        if newDirection != currentDirection {
            currentDirection = newDirection
            lastDirectionUpdate = currentTime
            
            let imageName = getImageName(for: newDirection)
            
            // 텍스처 캐시를 사용한 최적화된 이미지 로딩
            if let cachedTexture = TextureCache.shared.getTexture(named: imageName) {
                texture = cachedTexture
                maintainAspectRatio()
            } else {
                // 이미지 로딩 실패 시 기본 색상으로 대체
                texture = nil
                color = getFallbackColor()
                print("⚠️ 좀비 이미지 로딩 실패: \(imageName)")
            }
        }
    }
    
    // MARK: - Combat Methods
    /**
     좀비에게 데미지를 입힙니다.
     - Parameter damage: 입힐 데미지 (기본값: 1)
     - Returns: 좀비가 죽었는지 여부 (true: 죽음, false: 생존)
     - Note: 좀비가 죽어도 씬에서 제거하지 않습니다. 호출자가 제거를 담당해야 합니다.
     */
    @discardableResult
    func takeDamage(_ damage: Int = 1) -> Bool {
        currentHealth -= damage
        
        // 피격 효과 (Hit 토스트 메시지) - 죽든 살든 무조건 표시
        showHitMessage()
        
        // 체력이 0 이하가 되면 죽음 (제거는 호출자가 담당)
        if currentHealth <= 0 {
            return true // 죽었음을 반환
        }
        
        return false // 아직 살아있음
    }
    

    
    // MARK: - Getters
    func getType() -> ZombieType {
        return zombieType
    }
    
    func getHealth() -> Int {
        return currentHealth
    }
    
    func getMaxHealth() -> Int {
        return health
    }
}
