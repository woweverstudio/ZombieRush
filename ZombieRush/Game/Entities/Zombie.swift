//
//  Zombie.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit
import Foundation

enum ZombieType {
    case normal
    case fast
    case strong
}

class Zombie: SKSpriteNode {
    
    // MARK: - Properties
    private let zombieType: ZombieType
    private var moveSpeed: CGFloat
    private var health: Int
    private var currentHealth: Int
    private let spawnWave: Int  // 스폰된 웨이브 저장

    private weak var target: SKNode?
    
    // MARK: - Initialization
    init(type: ZombieType, currentWave: Int) {
        self.zombieType = type
        self.spawnWave = currentWave

        // 웨이브별 배수 적용
        let speedMultiplier = min(pow(GameBalance.Wave.speedMultiplier, Float(currentWave - 1)), GameBalance.Wave.maxSpeedMultiplier)
        let healthMultiplier = min(pow(GameBalance.Wave.healthMultiplier, Float(currentWave - 1)), GameBalance.Wave.maxHealthMultiplier)
        
        // 타입별 속성 설정
        let size: CGSize
        let color: SKColor
        
        switch type {
        case .normal:
            self.moveSpeed = GameBalance.Zombie.normalSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameBalance.Zombie.normalHealth) * healthMultiplier)
            size = GameBalance.Zombie.normalSize
            color = UIConstants.Colors.Neon.normalZombieColor
            
        case .fast:
            self.moveSpeed = GameBalance.Zombie.fastSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameBalance.Zombie.fastHealth) * healthMultiplier)
            size = GameBalance.Zombie.fastSize
            color = UIConstants.Colors.Neon.fastZombieColor
            
        case .strong:
            self.moveSpeed = GameBalance.Zombie.strongSpeed * CGFloat(speedMultiplier)
            self.health = Int(Float(GameBalance.Zombie.strongHealth) * healthMultiplier)
            size = GameBalance.Zombie.strongSize
            color = UIConstants.Colors.Neon.strongZombieColor
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
        name = TextConstants.NodeNames.zombie
        zPosition = 8
        
        // 물리 설정 - 사각형에 맞게 변경
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.worldBorder
        physicsBody?.linearDamping = GameBalance.Physics.zombieLinearDamping
        
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
        neonRect.position = CGPoint.zero
        neonRect.name = TextConstants.NodeNames.zombieShape
        
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
    
    // MARK: - Combat Methods
    @discardableResult
    func takeDamage(_ damage: Int = 1) -> Bool {
        currentHealth -= damage

        if currentHealth <= 0 {
            return true
        }

        return false
    }

    // MARK: - Stats Update Methods
    func updateStats(forWave wave: Int) {
        // 새로운 웨이브에 맞는 배수 계산
        let speedMultiplier = min(pow(GameBalance.Wave.speedMultiplier, Float(wave - 1)), GameBalance.Wave.maxSpeedMultiplier)
        let healthMultiplier = min(pow(GameBalance.Wave.healthMultiplier, Float(wave - 1)), GameBalance.Wave.maxHealthMultiplier)

        // 타입별 기본 스탯 가져오기
        let baseSpeed: CGFloat
        let baseHealth: Int

        switch zombieType {
        case .normal:
            baseSpeed = GameBalance.Zombie.normalSpeed
            baseHealth = GameBalance.Zombie.normalHealth
        case .fast:
            baseSpeed = GameBalance.Zombie.fastSpeed
            baseHealth = GameBalance.Zombie.fastHealth
        case .strong:
            baseSpeed = GameBalance.Zombie.strongSpeed
            baseHealth = GameBalance.Zombie.strongHealth
        }

        // 새로운 스탯 계산
        let newSpeed = baseSpeed * CGFloat(speedMultiplier)
        let newMaxHealth = Int(Float(baseHealth) * healthMultiplier)
        let healthIncrease = newMaxHealth - self.health

        // 스탯 업데이트 (스피드는 즉시 적용, 헬스는 현재 체력도 함께 증가)
        self.moveSpeed = newSpeed
        self.health = newMaxHealth
        self.currentHealth += healthIncrease

        // 체력이 최대치를 넘지 않도록 보장
        if currentHealth > health {
            currentHealth = health
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

    func getSpawnWave() -> Int {
        return spawnWave
    }
}
