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
    
    // 이미지 관련 프로퍼티 제거됨 - 단순한 사각형 사용
    
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
            color = GameConstants.NeonEffects.normalZombieNeonColor
            
        case .fast:
            self.moveSpeed = GameConstants.Zombie.fastSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.fastHealth) * healthMultiplier)
            size = GameConstants.Zombie.fastSize
            color = GameConstants.NeonEffects.fastZombieNeonColor
            
        case .strong:
            self.moveSpeed = GameConstants.Zombie.strongSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameConstants.Zombie.strongHealth) * healthMultiplier)
            size = GameConstants.Zombie.strongSize
            color = GameConstants.NeonEffects.strongZombieNeonColor
        }
        
        self.currentHealth = health
        
        // 네온 사각형으로 직접 초기화
        super.init(texture: nil, color: .clear, size: size)
        
        setupZombie(color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupZombie(color: SKColor) {
        name = GameConstants.NodeNames.zombie
        zPosition = 8
        
        // 물리 설정 - 사각형에 맞게 변경
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.worldBorder
        physicsBody?.linearDamping = GameConstants.Physics.zombieLinearDamping
        
        // 네온 사각형 직접 생성
        createNeonRectangle(color: color)
    }
    
    // MARK: - Neon Rectangle Creation
    private func createNeonRectangle(color: SKColor) {
        // 둥근 모서리 네온 사각형 ShapeNode 추가
        let rect = CGRect(
            x: -size.width/2, 
            y: -size.height/2, 
            width: size.width, 
            height: size.height
        )
        let neonRect = SKShapeNode(rect: rect, cornerRadius: 4) // 둥근 모서리 추가
        neonRect.fillColor = color
        neonRect.strokeColor = color
        neonRect.lineWidth = 2
        neonRect.glowWidth = GameConstants.NeonEffects.zombieGlowWidth
        neonRect.position = CGPoint.zero
        neonRect.name = "ZombieShape"
        
        addChild(neonRect)
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
    
    // 이미지 업데이트 메서드 제거됨 - 단순한 사각형 사용
    
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
