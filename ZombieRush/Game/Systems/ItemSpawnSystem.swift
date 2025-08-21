import SpriteKit

class ItemSpawnSystem {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private let gameStateManager = GameStateManager.shared
    
    private var activeItems: [Item] = []
    private var lastSpawnTime: TimeInterval = 0
    
    // MARK: - Spawn Configuration
    private let mapSize = CGSize(width: GameConstants.Physics.worldWidth, height: GameConstants.Physics.worldHeight)
    private let spawnMargin: CGFloat = GameConstants.Items.spawnMargin
    
    // MARK: - Callbacks
    var onItemCollected: ((ItemType) -> Void)?
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
        spawnInitialItems()
    }
    
    // MARK: - Public Methods
    func update(_ currentTime: TimeInterval) {
        // 모든 아이템의 나이 업데이트
        for item in activeItems {
            item.updateAge(currentTime: currentTime)
        }
        
        // 주기적으로 새 아이템 스폰
        if currentTime - lastSpawnTime >= GameConstants.Items.spawnInterval {
            spawnNewItem()
            lastSpawnTime = currentTime
        }
        
        // 오래된 아이템 정리
        cleanupOldItems(currentTime: currentTime)
    }
    
    func collectItem(_ item: Item) {
        guard let index = activeItems.firstIndex(of: item) else { return }
        
        // 아이템 제거
        activeItems.remove(at: index)
        item.collect()
        
        // 콜백 호출
        onItemCollected?(item.getType())
    }
    
    func removeAllItems() {
        activeItems.forEach { $0.removeFromParent() }
        activeItems.removeAll()
    }
    
    func getActiveItemCount() -> Int {
        return activeItems.count
    }
    
    // MARK: - Private Methods
    private func spawnInitialItems() {
        let initialCount = getCurrentMaxItemCount()
        for _ in 0..<initialCount {
            spawnRandomItem()
        }
    }
    
    private func spawnNewItem() {
        let currentCount = activeItems.count
        let maxCount = getCurrentMaxItemCount()
        
        // 최대 개수에 도달하지 않았을 때만 스폰
        if currentCount < maxCount {
            spawnRandomItem()
        }
    }
    
    private func spawnRandomItem() {
        guard let worldNode = worldNode else { return }
        
        // 현재 웨이브에 따른 아이템 타입 선택
        let itemType = getRandomItemType()
        
        // 랜덤 위치 생성
        let position = generateRandomPosition()
        
        // 아이템 생성
        let item = Item(type: itemType)
        item.position = position
        
        // 월드에 추가
        worldNode.addChild(item)
        activeItems.append(item)
    }
    
    private func generateRandomPosition() -> CGPoint {
        let halfWidth = mapSize.width / 2 - spawnMargin
        let halfHeight = mapSize.height / 2 - spawnMargin
        
        let x = CGFloat.random(in: -halfWidth...halfWidth)
        let y = CGFloat.random(in: -halfHeight...halfHeight)
        
        return CGPoint(x: x, y: y)
    }
    
    private func getCurrentMaxItemCount() -> Int {
        let waveNumber = gameStateManager.getCurrentWaveNumber()
        let multiplier = pow(GameConstants.Items.spawnCountMultiplier, Float(waveNumber - 1))
        let count = Int(Float(GameConstants.Items.baseSpawnCount) * multiplier)
        
        return min(count, GameConstants.Items.maxSpawnCount)
    }
    
    private func cleanupOldItems(currentTime: TimeInterval) {
        activeItems.removeAll { item in
            let age = item.getAge(currentTime: currentTime)
            if age >= GameConstants.Items.lifetime {
                item.removeFromParent()
                return true
            }
            return false
        }
    }
    
    // MARK: - Debug Methods
    func getItemCounts() -> [ItemType: Int] {
        var counts: [ItemType: Int] = [:]
        
        for type in ItemType.allCases {
            counts[type] = activeItems.filter { $0.getType() == type }.count
        }
        
        return counts
    }
    
    private func getRandomItemType() -> ItemType {
        let currentWave = gameStateManager.getCurrentWaveNumber()
        
        // 현재 웨이브에서 사용 가능한 아이템 타입 필터링
        let availableTypes = ItemType.allCases.filter { itemType in
            switch itemType {
            case .healthRestore, .ammoRestore:
                return true  // 웨이브 1부터 항상 사용 가능
            case .speedBoost:
                return currentWave >= GameConstants.Items.speedBoostMinWave
            case .invincibility:
                return currentWave >= GameConstants.Items.invincibilityMinWave
            case .shotgun:
                return currentWave >= GameConstants.Items.shotgunMinWave
            case .meteor:
                return currentWave >= GameConstants.Items.meteorMinWave
            }
        }
        
        return availableTypes.randomElement() ?? .healthRestore
    }
}
