import SpriteKit

class Meteor: SKSpriteNode {
    
    // MARK: - Properties
    private let damage: Int
    private var hasExploded: Bool = false
    private let explosionPosition: CGPoint
    
    // MARK: - Initialization
    init(at position: CGPoint) {
        self.damage = GameBalance.Items.meteorDamage
        self.explosionPosition = position
        
        super.init(texture: nil, color: .clear, size: CGSize(width: UIConstants.ItemVisual.meteorIndicatorSize, height: UIConstants.ItemVisual.meteorIndicatorSize))
        setupMeteor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupMeteor() {
        name = TextConstants.NodeNames.meteor
        zPosition = 10
        position = explosionPosition
        
        // 경고 표시기 생성
        createWarningIndicator()
        
        // 1초 후 폭발
        scheduleExplosion()
    }
    
    private func createWarningIndicator() {
        // 간단한 원형 경고 표시기 (시야 방해 최소화)
        let warningCircle = SKShapeNode(circleOfRadius: UIConstants.ItemVisual.meteorIndicatorSize / 2)
        warningCircle.fillColor = .clear
        warningCircle.strokeColor = UIConstants.Colors.Items.meteorWarningColor
        warningCircle.lineWidth = UIConstants.ItemVisual.meteorWarningLineWidth
        warningCircle.glowWidth = UIConstants.ItemVisual.meteorWarningGlowWidth
        warningCircle.alpha = UIConstants.ItemVisual.meteorWarningAlpha
        addChild(warningCircle)
        
        // 중앙 점
        let centerDot = SKShapeNode(circleOfRadius: UIConstants.ItemVisual.meteorCenterDotSize)
        centerDot.fillColor = UIConstants.Colors.Items.meteorWarningColor
        centerDot.strokeColor = .clear
        centerDot.glowWidth = 1
        addChild(centerDot)
        
        // 깜빡이는 애니메이션
        let blinkAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        let repeatBlink = SKAction.repeat(blinkAction, count: 5) // 1초간 깜빡임
        run(repeatBlink)
    }
    
    private func scheduleExplosion() {
        let waitAction = SKAction.wait(forDuration: GameBalance.Items.meteorDelayBeforeExplosion)
        let explodeAction = SKAction.run { [weak self] in
            self?.explode()
        }
        
        run(SKAction.sequence([waitAction, explodeAction]))
    }
    
    private func explode() {
        guard !hasExploded else { return }
        hasExploded = true
        
        // 경고 표시기 제거
        removeAllChildren()
        
        // 폭발 소리 재생
        if AudioManager.shared.isSoundEffectsEnabled,
           let worldNode = parent {
            let meteorSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.meteor, waitForCompletion: false)
            worldNode.run(meteorSound)
        }
        
        // 폭발 효과 생성
        let explosion = createExplosionEffect()
        parent?.addChild(explosion)
        explosion.position = position
        
        // 직접 주변 좀비들을 찾아서 데미지 적용
        damageZombiesInExplosionRadius()
        
        // 메테오 제거
        removeFromParent()
    }
    
    private func damageZombiesInExplosionRadius() {
        guard let worldNode = parent else { return }
        
        // 폭발 반지름 내의 모든 좀비 찾기
        let explosionRadius = GameBalance.Items.meteorExplosionRadius
        
        worldNode.enumerateChildNodes(withName: TextConstants.NodeNames.zombie) { [weak self] node, _ in
            guard let zombie = node as? Zombie,
                  let meteorPosition = self?.position else { return }
            
            // 거리 계산
            let distance = sqrt(pow(zombie.position.x - meteorPosition.x, 2) + pow(zombie.position.y - meteorPosition.y, 2))
            
            // 폭발 범위 내에 있으면 즉사 데미지
            if distance <= explosionRadius {
                let isDead = zombie.takeDamage(self?.getDamage() ?? GameBalance.Items.meteorDamage)
                
                // GameScene에 좀비 제거 알림
                if isDead, let scene = worldNode.scene as? GameScene {
                    scene.addScore()
                    scene.removeZombie(zombie)
                }
            }
        }
    }
    

    
    private func createExplosionEffect() -> SKNode {
        let explosionNode = SKNode()
        
        // 외부 폭발 링
        let outerRing = SKShapeNode(circleOfRadius: GameBalance.Items.meteorExplosionRadius)
        outerRing.fillColor = .clear
        outerRing.strokeColor = UIConstants.Colors.Items.meteorExplosionOuterColor
        outerRing.lineWidth = UIConstants.ItemVisual.meteorExplosionLineWidth
        outerRing.glowWidth = UIConstants.ItemVisual.meteorExplosionGlowWidth
        outerRing.alpha = 0.9
        explosionNode.addChild(outerRing)
        
        // 내부 폭발 원
        let innerCircle = SKShapeNode(circleOfRadius: GameBalance.Items.meteorInnerExplosionRadius)
        innerCircle.fillColor = UIConstants.Colors.Items.meteorExplosionInnerColor
        innerCircle.strokeColor = .clear
        innerCircle.alpha = 0.8
        explosionNode.addChild(innerCircle)
        
        // 중앙 밝은 점
        let centerFlash = SKShapeNode(circleOfRadius: GameBalance.Items.meteorCenterFlashRadius)
        centerFlash.fillColor = .white
        centerFlash.strokeColor = .clear
        centerFlash.glowWidth = 3
        explosionNode.addChild(centerFlash)
        
        // 폭발 애니메이션
        let scaleUp = SKAction.scale(to: GameBalance.Items.meteorExplosionScale, duration: GameBalance.Items.meteorExplosionDuration)
        let fadeOut = SKAction.fadeOut(withDuration: GameBalance.Items.meteorExplosionDuration)
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
    
    func getHasExploded() -> Bool {
        return hasExploded
    }
}
