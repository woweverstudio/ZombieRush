//
//  Bullet.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class Bullet: SKSpriteNode {
    
    // MARK: - Properties
    private let bulletSpeed: CGFloat = GameConstants.Bullet.speed
    private let lifetime: TimeInterval = GameConstants.Bullet.lifetime
    
    // MARK: - Initialization
    init() {
        let size = GameConstants.Bullet.size
        super.init(texture: nil, color: .clear, size: size)
        
        setupBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupBullet() {
        name = GameConstants.NodeNames.bullet
        zPosition = 5
        
        // 흰색 동그라미 생성
        let circle = SKShapeNode(circleOfRadius: size.width / 2)
        circle.fillColor = .white
        circle.strokeColor = .white
        circle.lineWidth = 1
        addChild(circle)
        
        // 물리 설정 (원형으로 변경)
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.bullet
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    // MARK: - Fire Bullet
    func fire(from startPosition: CGPoint, direction: CGVector) {
        position = startPosition
        
        // 총알 속도 설정
        let velocity = CGVector(
            dx: direction.dx * bulletSpeed,
            dy: direction.dy * bulletSpeed
        )
        physicsBody?.velocity = velocity
        
        // 일정 시간 후 총알 제거
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: lifetime),
            SKAction.removeFromParent()
        ])
        run(removeAction)
    }
}
