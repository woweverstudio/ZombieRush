//
//  ZombieSpawner.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class ZombieSpawner {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private weak var player: Player?
    private let gameStateManager = GameStateManager.shared
    
    // MARK: - Callbacks
    var onNewWaveStarted: ((Int) -> Void)?
    
    private var lastSpawnTime: TimeInterval = 0
    private var baseSpawnInterval: TimeInterval = 1.0  // 초기 스폰 간격을 1초로 단축
    private var zombies: [Zombie] = []
    
    // MARK: - Spawn Configuration
    private let mapSize: CGSize = CGSize(width: 2000, height: 2000)
    private let spawnDistance: CGFloat = 100 // 맵 가장자리에서 얼마나 안쪽에서 스폰할지
    
    // MARK: - Performance Optimization
    private let maxZombieCount: Int = 50 // 최대 좀비 수 제한 (성능 최적화)
    private var zombieUpdateBatchSize: Int = 10 // 한 프레임에 업데이트할 좀비 수
    private var zombieUpdateIndex: Int = 0
    
    // MARK: - Initialization
    init(worldNode: SKNode, player: Player) {
        self.worldNode = worldNode
        self.player = player
    }
    
    // MARK: - Spawning
    func update(_ currentTime: TimeInterval) {
        // 웨이브 시스템 업데이트 확인
        let newWaveStarted = gameStateManager.updateWaveSystem(currentTime: currentTime)
        if newWaveStarted {
            handleNewWave()
        }
        
        // 웨이브별 난이도 적용
        let zombieCountMultiplier = gameStateManager.getZombieCountMultiplier()
        let adjustedSpawnInterval = baseSpawnInterval / Double(zombieCountMultiplier)
        
        if currentTime - lastSpawnTime >= adjustedSpawnInterval {
            spawnZombie()
            lastSpawnTime = currentTime
        }
        
        updateZombies()
    }
    
    private func handleNewWave() {
        // 스폰 타이머 리셋
        lastSpawnTime = 0
        
        // 웨이브 시작 콜백 호출
        let currentWave = gameStateManager.getCurrentWaveNumber()
        onNewWaveStarted?(currentWave)
    }
    
    private func spawnZombie() {
        guard let worldNode = worldNode, let player = player else { return }
        
        // 성능 최적화: 최대 좀비 수 제한
        guard zombies.count < maxZombieCount else { return }
        
        let zombieType = getRandomZombieType()
        let zombie = Zombie(type: zombieType)
        
        // 맵 가장자리에서 랜덤 위치 생성
        let spawnPosition = getRandomSpawnPosition()
        zombie.position = spawnPosition
        zombie.setTarget(player)
        
        worldNode.addChild(zombie)
        zombies.append(zombie)
    }
    
    private func getRandomZombieType() -> ZombieType {
        let random = Int.random(in: 1...100)
        
        switch random {
        case 1...60:    return .normal  // 60% 확률
        case 61...85:   return .fast    // 25% 확률
        case 86...100:  return .strong  // 15% 확률
        default:        return .normal
        }
    }
    
    private func getRandomSpawnPosition() -> CGPoint {
        guard let player = player else { return CGPoint.zero }
        
        let edge = Int.random(in: 0...3) // 0: 상, 1: 우, 2: 하, 3: 좌
        
        var spawnX: CGFloat = 0
        var spawnY: CGFloat = 0
        
        switch edge {
        case 0: // 상단
            spawnX = CGFloat.random(in: -mapSize.width/2...mapSize.width/2)
            spawnY = mapSize.height/2 - spawnDistance
            
        case 1: // 우측
            spawnX = mapSize.width/2 - spawnDistance
            spawnY = CGFloat.random(in: -mapSize.height/2...mapSize.height/2)
            
        case 2: // 하단
            spawnX = CGFloat.random(in: -mapSize.width/2...mapSize.width/2)
            spawnY = -mapSize.height/2 + spawnDistance
            
        case 3: // 좌측
            spawnX = -mapSize.width/2 + spawnDistance
            spawnY = CGFloat.random(in: -mapSize.height/2...mapSize.height/2)
            
        default:
            break
        }
        
        return CGPoint(x: spawnX, y: spawnY)
    }
    
    private func updateZombies() {
        // 죽은 좀비들을 먼저 제거
        zombies.removeAll { zombie in
            zombie.parent == nil
        }
        
        // 성능 최적화: 배치로 좀비 업데이트 (한 프레임에 모든 좀비를 업데이트하지 않음)
        let zombieCount = zombies.count
        guard zombieCount > 0 else { 
            zombieUpdateIndex = 0 // 좀비가 없으면 인덱스 리셋
            return 
        }
        
        // 인덱스가 배열 크기를 초과하지 않도록 보정
        if zombieUpdateIndex >= zombieCount {
            zombieUpdateIndex = 0
        }
        
        let endIndex = min(zombieUpdateIndex + zombieUpdateBatchSize, zombieCount)
        
        // 안전한 범위 체크
        if zombieUpdateIndex < endIndex && zombieUpdateIndex < zombieCount {
            for i in zombieUpdateIndex..<endIndex {
                if i < zombies.count {
                    zombies[i].update()
                }
            }
        }
        
        // 다음 배치를 위한 인덱스 업데이트
        zombieUpdateIndex = endIndex
        if zombieUpdateIndex >= zombieCount {
            zombieUpdateIndex = 0 // 다시 처음부터
        }
    }
    
    // MARK: - Public Methods
    /**
     좀비를 완전히 제거합니다.
     - Parameter zombie: 제거할 좀비
     - Note: 배열에서 제거 후 씬에서도 제거합니다.
     */
    func removeZombie(_ zombie: Zombie) {
        // 배열에서 제거
        if let index = zombies.firstIndex(of: zombie) {
            zombies.remove(at: index)
            
            // 인덱스 조정: 제거된 좀비의 인덱스가 현재 업데이트 인덱스보다 작거나 같으면 조정
            if index <= zombieUpdateIndex && zombieUpdateIndex > 0 {
                zombieUpdateIndex -= 1
            }
            
            // 인덱스가 배열 크기를 초과하지 않도록 보정
            if zombieUpdateIndex >= zombies.count {
                zombieUpdateIndex = max(0, zombies.count - 1)
            }
        }
        
        // 씬에서 제거
        zombie.removeFromParent()
    }
    
    func getAllZombies() -> [Zombie] {
        return zombies
    }
    
    func getZombieCount() -> Int {
        return zombies.count
    }
    
    func removeAllZombies() {
        // 모든 좀비를 씬에서 제거
        for zombie in zombies {
            zombie.removeFromParent()
        }
        
        // 배열 초기화
        zombies.removeAll()
        
        // 인덱스 리셋
        zombieUpdateIndex = 0
    }
}
