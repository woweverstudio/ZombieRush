import SpriteKit

class Meteor: SKSpriteNode {
    
    // MARK: - Properties
    private let damage: Int
    private var hasHit: Bool = false
    
    // MARK: - Initialization
    init() {
        self.damage = GameConstants.Items.meteorDamage
        
        super.init(texture: nil, color: .orange, size: CGSize(width: GameConstants.Items.meteorSize, height: GameConstants.Items.meteorSize))
        setupMeteor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupMeteor() {
        name = GameConstants.NodeNames.meteor
        zPosition = 15  // 높은 우선순위로 표시
        
        // 운석 시각적 효과
        createMeteorVisual()
        
        // 물리 설정
        setupPhysics()
        
        // 낙하 애니메이션
        playFallAnimation()
    }
    
    private func createMeteorVisual() {
        // 네온 스타일 메테오 (둥근 사각형)
        let visualSize = GameConstants.Items.meteorSize * 0.4
        let meteorRect = CGRect(x: -visualSize/2, y: -visualSize/2, width: visualSize, height: visualSize)
        
        // 외부 주황색 네온 사각형
        let meteorBody = SKShapeNode(rect: meteorRect, cornerRadius: 4)
        meteorBody.fillColor = .orange
        meteorBody.strokeColor = .orange
        meteorBody.lineWidth = 2
        meteorBody.glowWidth = 4
        addChild(meteorBody)
        
        // 내부 빨간 사각형
        let innerSize = visualSize * 0.6
        let innerRect = CGRect(x: -innerSize/2, y: -innerSize/2, width: innerSize, height: innerSize)
        let innerBody = SKShapeNode(rect: innerRect, cornerRadius: 2)
        innerBody.fillColor = .red
        innerBody.strokeColor = .red
        innerBody.lineWidth = 1
        innerBody.glowWidth = 2
        addChild(innerBody)
    }
    
    private func setupPhysics() {
        // 큰 불꽃 효과 원 기준으로 충돌 범위 설정 (더 직관적)
        let fireEffectRadius = GameConstants.Items.meteorSize / 2 + GameConstants.Items.meteorFireEffectOffset
        physicsBody = SKPhysicsBody(circleOfRadius: fireEffectRadius)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.meteor
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.affectedByGravity = false
    }
    
    private func playFallAnimation() {
        // 회전 효과
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameConstants.Items.meteorRotationDuration)
        let repeatRotate = SKAction.repeatForever(rotateAction)
        run(repeatRotate)
        
        // 낙하 후 폭발
        let fallAction = SKAction.wait(forDuration: GameConstants.Items.meteorFallDuration)
        let explodeAction = SKAction.run { [weak self] in
            self?.explode()
        }
        
        run(SKAction.sequence([fallAction, explodeAction]))
    }
    
    private func explode() {
        guard !hasHit else { return }
        hasHit = true
        
        // 폭발 효과
        let explosion = createExplosionEffect()
        parent?.addChild(explosion)
        explosion.position = position
        
        // 주변 좀비 데미지 처리는 PhysicsSystem에서 처리
        
        // 운석 제거
        let removalAction = AnimationUtils.createScaleUpAndRemove(
            scale: GameConstants.Items.meteorRemovalScale, 
            duration: GameConstants.Items.meteorRemovalDuration
        )
        run(removalAction)
    }
    
    private func createExplosionEffect() -> SKNode {
        let explosionNode = SKNode()
        
        // 폭발 원
        let explosionCircle = SKShapeNode(circleOfRadius: GameConstants.Items.meteorExplosionRadius)
        explosionCircle.fillColor = .yellow
        explosionCircle.strokeColor = .orange
        explosionCircle.lineWidth = GameConstants.Items.meteorLineWidth + 2
        explosionCircle.alpha = 0.9
        explosionNode.addChild(explosionCircle)
        
        // 내부 폭발 효과
        let innerExplosion = SKShapeNode(circleOfRadius: GameConstants.Items.meteorInnerExplosionRadius)
        innerExplosion.fillColor = .white
        innerExplosion.alpha = 0.7
        explosionNode.addChild(innerExplosion)
        
        // 폭발 애니메이션
        let scaleUp = SKAction.scale(to: GameConstants.Items.meteorExplosionScale, duration: GameConstants.Items.meteorExplosionDuration)
        let fadeOut = SKAction.fadeOut(withDuration: GameConstants.Items.meteorExplosionDuration)
        let remove = SKAction.removeFromParent()
        
        explosionNode.run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
        
        return explosionNode
    }
    
    // MARK: - Public Methods
    func getDamage() -> Int {
        return damage
    }
    
    func getHasHit() -> Bool {
        return hasHit
    }
}
