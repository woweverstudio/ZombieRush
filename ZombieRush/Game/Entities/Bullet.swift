//
//  Bullet.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class Bullet: SKSpriteNode {
    
    // MARK: - Properties
    private let bulletSpeed: CGFloat = GameBalance.Bullet.speed
    private let lifetime: TimeInterval = GameBalance.Bullet.lifetime
    
    // MARK: - Initialization
    init() {
        let size = GameBalance.Bullet.size
        super.init(texture: nil, color: .clear, size: size)
        
        setupBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupBullet() {
        name = TextConstants.NodeNames.bullet
        zPosition = 5
        
        // 네온 사이버펑크 스타일 총알 생성
        createNeonBullet()
        
        // 물리 설정 (원형으로 변경)
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.bullet
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    private func createNeonBullet() {
        // 네온 청록색 총알 - 둥근 사각형 스타일
        let bulletRect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        
        let neonBullet = SKShapeNode(rect: bulletRect, cornerRadius: size.width / 4)
        
        // 네온 청록색 설정
        neonBullet.fillColor = UIConstants.Colors.Neon.bulletColor
        neonBullet.strokeColor = UIConstants.Colors.Neon.bulletStrokeColor
        neonBullet.lineWidth = 1.5
        neonBullet.glowWidth = UIConstants.Colors.Neon.bulletGlowWidth
        
        // 내부 코어 (더 밝은 중심)
        let coreSize = CGSize(width: size.width * 0.6, height: size.height * 0.6)
        let coreRect = CGRect(
            x: -coreSize.width / 2,
            y: -coreSize.height / 2,
            width: coreSize.width,
            height: coreSize.height
        )
        
        let core = SKShapeNode(rect: coreRect, cornerRadius: coreSize.width / 4)
        core.fillColor = UIConstants.Colors.Neon.bulletCoreColor
        core.strokeColor = .clear
        core.glowWidth = UIConstants.Colors.Neon.bulletCoreGlowWidth
        
        neonBullet.addChild(core)
        addChild(neonBullet)
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
