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
    
    var imageName: String {
        switch self {
        case .speedBoost: return ResourceConstants.Images.Items.speedBoost
        case .healthRestore: return ResourceConstants.Images.Items.healthRestore
        case .ammoRestore: return ResourceConstants.Images.Items.ammoRestore
        case .invincibility: return ResourceConstants.Images.Items.invincibility
        case .shotgun: return ResourceConstants.Images.Items.shotgun
        case .meteor: return ResourceConstants.Images.Items.meteor
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
        
        // 안전한 이미지 로딩
        let texture = SKTexture(imageNamed: type.imageName)
        let textureSize = texture.size()
        
        if textureSize.width > 1 && textureSize.height > 1 {
            // 이미지가 있으면 이미지 사용
            super.init(texture: texture, color: .clear, size: GameBalance.Items.size)
        } else {
            // 이미지가 없으면 색상 사각형으로 대체
            let fallbackColor: SKColor
            switch type {
            case .healthRestore: fallbackColor = .red
            case .ammoRestore: fallbackColor = .orange
            case .speedBoost: fallbackColor = .cyan
            case .invincibility: fallbackColor = .yellow
            case .shotgun: fallbackColor = .purple
            case .meteor: fallbackColor = .brown
            }
            super.init(texture: nil, color: fallbackColor, size: GameBalance.Items.size)
        }
        
        setupItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupItem() {
        name = TextConstants.NodeNames.item
        zPosition = UIConstants.ItemVisual.zPosition
        
        // 이미지 비율 유지
        maintainAspectRatio()
        
        // 물리 설정
        setupPhysics()
        
        // 등장 애니메이션
        playSpawnAnimation()
        
        // 생명주기 관리
        setupLifetime()
    }
    
    private func maintainAspectRatio() {
        guard let texture = texture else { 
            // 텍스처가 없으면 기본 사이즈 사용 (색상 사각형인 경우)
            size = GameBalance.Items.size
            return 
        }
        let originalSize = texture.size()
        let targetSize = GameBalance.Items.size
        
        // 원본 비율을 유지하면서 targetSize에 맞춤 (aspect fit)
        let scaleX = targetSize.width / originalSize.width
        let scaleY = targetSize.height / originalSize.height
        let scale = min(scaleX, scaleY)
        
        size = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: GameBalance.Items.size.width / 2)
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
        let lifetime = SKAction.wait(forDuration: GameBalance.Items.lifetime)
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
