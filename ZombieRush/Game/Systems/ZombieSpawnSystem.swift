//
//  ZombieSpawnSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class ZombieSpawnSystem {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private weak var player: Player?
    private let gameStateManager = GameStateManager.shared
    
    // MARK: - Callbacks
    var onNewWaveStarted: ((Int) -> Void)?
    
    private var lastSpawnTime: TimeInterval = 0
    private var baseSpawnInterval: TimeInterval = GameBalance.Zombie.baseSpawnInterval
    private var zombies: [Zombie] = []
    
    private let mapSize: CGSize = CGSize(width: GameBalance.Physics.worldWidth, height: GameBalance.Physics.worldHeight)
    private let spawnDistance: CGFloat = GameBalance.Zombie.spawnDistance
    
    private let maxZombieCount: Int = 60
    private let zombieUpdateBatchSize: Int = 15
    private var zombieUpdateIndex: Int = 0
    
    // MARK: - Initialization
    init(worldNode: SKNode, player: Player) {
        self.worldNode = worldNode
        self.player = player
    }
    
    func update(_ currentTime: TimeInterval) {
        let newWaveStarted = gameStateManager.updateWaveSystem(currentTime: currentTime)
        if newWaveStarted {
            handleNewWave()
        }

        let zombieCountMultiplier = gameStateManager.getZombieCountMultiplier()
        let adjustedSpawnInterval = baseSpawnInterval / Double(zombieCountMultiplier)

        if currentTime - lastSpawnTime >= adjustedSpawnInterval {
            spawnZombie()
            lastSpawnTime = currentTime
        }

        updateZombies()
    }
    
    private func handleNewWave() {
        lastSpawnTime = 0
        let currentWave = gameStateManager.getCurrentWaveNumber()
        onNewWaveStarted?(currentWave)
    }
    
    private func spawnZombie() {
        guard let worldNode = worldNode, let player = player else { return }

        // 스폰 전에 다시 한 번 확인 (동시성 안전)
        guard zombies.count < maxZombieCount else { return }

        let zombieType = getRandomZombieType()
        let zombie = Zombie(type: zombieType)
        let spawnPosition = getRandomSpawnPosition()

        zombie.position = spawnPosition
        zombie.setTarget(player)

        // 씬에 추가 후 배열에 추가 (실패 시 롤백)
        worldNode.addChild(zombie)

        // 최종 확인 후 추가
        if zombies.count < maxZombieCount {
            zombies.append(zombie)
        } else {
            // 최대 수 초과 시 방금 추가한 좀비 제거
            zombie.removeFromParent()
        }
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
        guard player != nil else { return .zero }

        let edge = Int.random(in: 0...3)
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
        // 죽은 좀비들을 먼저 제거 (parent가 nil인 경우)
        zombies.removeAll { zombie in
            zombie.parent == nil
        }

        let zombieCount = zombies.count
        guard zombieCount > 0 else {
            zombieUpdateIndex = 0
            return
        }

        // 안전한 인덱스 범위 보장
        if zombieUpdateIndex >= zombieCount {
            zombieUpdateIndex = 0
        }

        let endIndex = min(zombieUpdateIndex + zombieUpdateBatchSize, zombieCount)
        let safeStartIndex = min(zombieUpdateIndex, zombieCount - 1)
        let safeEndIndex = min(endIndex, zombieCount)

        // 안전한 범위 내에서만 업데이트
        guard safeStartIndex < safeEndIndex else {
            zombieUpdateIndex = 0
            return
        }

        for i in safeStartIndex..<safeEndIndex {
            if i < zombies.count {  // 추가 안전 체크
                zombies[i].update()
            }
        }

        zombieUpdateIndex = (safeEndIndex >= zombieCount) ? 0 : safeEndIndex
    }
    
    func removeZombie(_ zombie: Zombie) {
        guard let index = zombies.firstIndex(of: zombie) else {
            zombie.removeFromParent() // 안전하게 노드만 제거
            return
        }

        zombies.remove(at: index)

        // 인덱스 조정: 제거된 위치가 현재 업데이트 인덱스보다 작거나 같으면 조정
        if index <= zombieUpdateIndex && zombieUpdateIndex > 0 {
            zombieUpdateIndex = max(0, zombieUpdateIndex - 1)
        }

        // 범위 초과 방지
        if zombieUpdateIndex >= zombies.count && zombies.count > 0 {
            zombieUpdateIndex = zombies.count - 1
        } else if zombies.isEmpty {
            zombieUpdateIndex = 0
        }

        zombie.removeFromParent()
    }
    
    func removeAllZombies() {
        // 안전하게 모든 좀비 제거
        let zombiesToRemove = zombies  // 복사본 사용으로 안전성 보장

        for zombie in zombiesToRemove {
            zombie.removeFromParent()
        }

        zombies.removeAll()
        zombieUpdateIndex = 0
    }
}
