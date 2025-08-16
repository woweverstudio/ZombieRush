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
    
    // MARK: - Initialization
    init(type: ZombieType) {
        self.zombieType = type
        
        // 웨이브별 배수 적용
        let speedMultiplier = GameStateManager.shared.getZombieSpeedMultiplier()
        let healthMultiplier = GameStateManager.shared.getZombieHealthMultiplier()
        
        // 타입별 속성 설정
        let size: CGSize
        let color: SKColor
        
        switch type {
        case .normal:
            self.moveSpeed = GameConstants.Zombie.normalSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.normalHealth) * healthMultiplier)
            size = GameConstants.Zombie.normalSize
            color = .green
            
        case .fast:
            self.moveSpeed = GameConstants.Zombie.fastSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.fastHealth) * healthMultiplier)
            size = GameConstants.Zombie.fastSize
            color = .yellow
            
        case .strong:
            self.moveSpeed = GameConstants.Zombie.strongSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.strongHealth) * healthMultiplier)
            size = GameConstants.Zombie.strongSize
            color = .red
        }
        
        self.currentHealth = health
        
        super.init(texture: nil, color: color, size: size)
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
            
            physicsBody?.velocity = velocity
        }
    }
    
    // MARK: - Combat Methods
    @discardableResult
    func takeDamage(_ damage: Int = 1) -> Bool {
        currentHealth -= damage
        
        // 체력이 0 이하가 되면 죽음
        if currentHealth <= 0 {
            removeFromParent()
            return true // 죽었음을 반환
        }
        
        // 피격 효과 (색상 변경)
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: getOriginalColor(), colorBlendFactor: 1.0, duration: 0.1)
        ])
        run(flashAction)
        
        return false // 아직 살아있음
    }
    
    private func getOriginalColor() -> SKColor {
        switch zombieType {
        case .normal: return .green
        case .fast: return .yellow
        case .strong: return .red
        }
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
