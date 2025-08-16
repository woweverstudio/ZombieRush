import SpriteKit

// MARK: - Item Types
enum ItemType: CaseIterable {
    case speedBoost      // 이동속도 증가
    case healthRestore   // 체력회복
    case ammoRestore     // 탄약 충전
    case invincibility   // 무적상태
    case shotgun         // 샷건발사
    case meteor          // 메테오 (웨이브 7+)
    
    var name: String {
        switch self {
        case .speedBoost: return "Speed Boost"
        case .healthRestore: return "Health Restore"
        case .ammoRestore: return "Ammo Restore"
        case .invincibility: return "Invincibility"
        case .shotgun: return "Shotgun"
        case .meteor: return "Meteor"
        }
    }
    
    var color: SKColor {
        switch self {
        case .speedBoost: return .cyan
        case .healthRestore: return .green
        case .ammoRestore: return .blue
        case .invincibility: return .yellow
        case .shotgun: return .orange
        case .meteor: return .red
        }
    }
    
    var isInstantEffect: Bool {
        switch self {
        case .healthRestore, .ammoRestore: return true
        case .speedBoost, .invincibility, .shotgun, .meteor: return false
        }
    }
}

// MARK: - Item Effect Protocol
protocol ItemEffect {
    func apply(to player: Player)
    func remove(from player: Player)
    var duration: TimeInterval { get }
    var isInstant: Bool { get }
}

// MARK: - Item Class
class Item: SKSpriteNode {
    
    // MARK: - Properties
    private let itemType: ItemType
    private let effect: ItemEffect
    private var spawnTime: TimeInterval = 0
    private var hasSetSpawnTime: Bool = false
    
    // MARK: - Initialization
    init(type: ItemType) {
        self.itemType = type
        self.effect = ItemEffectFactory.createEffect(for: type)
        
        super.init(texture: nil, color: type.color, size: GameConstants.Items.size)
        print("🎁 Item 초기화: \(type)")
        setupItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupItem() {
        name = GameConstants.NodeNames.item
        zPosition = GameConstants.Items.zPosition
        
        print("🎁 Item 설정 시작: \(itemType), color: \(itemType.color)")
        
        // 원형으로 만들기
        let circle = SKShapeNode(circleOfRadius: GameConstants.Items.size.width / 2)
        circle.fillColor = itemType.color
        circle.strokeColor = SKColor.white
        circle.lineWidth = 2
        addChild(circle)
        
        print("🎁 Item 시각적 요소 추가 완료")
        
        // 물리 설정
        setupPhysics()
        
        // 등장 애니메이션
        playSpawnAnimation()
        
        // 생명주기 관리
        setupLifetime()
        
        print("🎁 Item 설정 완료: \(itemType)")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: GameConstants.Items.size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.item
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    private func playSpawnAnimation() {
        alpha = 0
        setScale(0.1)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let spawn = SKAction.group([fadeIn, scaleUp])
        
        // 부드러운 펄스 효과
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        run(SKAction.sequence([spawn, repeatPulse]))
    }
    
    private func setupLifetime() {
        let lifetime = SKAction.wait(forDuration: GameConstants.Items.lifetime)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([lifetime, fadeOut, remove])
        run(sequence, withKey: "lifetime")
    }
    
    // MARK: - Public Methods
    func getType() -> ItemType {
        return itemType
    }
    
    func getEffect() -> ItemEffect {
        return effect
    }
    
    func collect() {
        // 수집 애니메이션
        removeAction(forKey: "lifetime")
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let collect = SKAction.group([scaleUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([collect, remove]))
    }
    
    func updateAge(currentTime: TimeInterval) {
        if !hasSetSpawnTime {
            spawnTime = currentTime
            hasSetSpawnTime = true
        }
    }
    
    func getAge(currentTime: TimeInterval) -> TimeInterval {
        if !hasSetSpawnTime {
            return 0
        }
        return currentTime - spawnTime
    }
}
