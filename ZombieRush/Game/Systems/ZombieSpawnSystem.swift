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
    
    private var zombies: [Zombie] = []

    // 웨이브별 스폰 관리를 위한 변수들
    private var maxZombieCount: Int = GameBalance.Zombie.baseMaxZombies
    private var currentWave: Int = 1
    private var lastSpawnTime: TimeInterval = 0
    private var lastLogTime: TimeInterval = 0

    // 상수들
    private let mapSize: CGSize = CGSize(width: GameBalance.Physics.worldWidth, height: GameBalance.Physics.worldHeight)
    private let spawnDistance: CGFloat = GameBalance.Zombie.spawnDistance
    
    // MARK: - Initialization
    init(worldNode: SKNode, player: Player) {
        self.worldNode = worldNode
        self.player = player

        // 초기화 시점에 현재 웨이브에 맞는 최대 좀비 수 설정
        let currentWave = gameStateManager.getCurrentWaveNumber()
        updateMaxZombieCount(for: currentWave)

        for _ in 0..<maxZombieCount {
            spawnZombie(currentWave: currentWave)
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        let newWaveStarted = gameStateManager.updateWaveSystem(currentTime: currentTime)
        let newCurrentWave = gameStateManager.getCurrentWaveNumber()

        // 웨이브가 변경되었을 때만 최대 좀비 수 업데이트
        if newCurrentWave != currentWave {
            currentWave = newCurrentWave
            updateMaxZombieCount(for: currentWave)
        }

        if newWaveStarted {
            handleNewWave()
        }

        // 웨이브별 스폰 방식 적용
        if currentWave <= 8 {
            // 웨이브 1-8: 스폰 인터벌 없이 즉시 채우기
            while zombies.count < maxZombieCount {
                spawnZombie(currentWave: currentWave)
            }
        } else {
            // 웨이브 8+: 스폰 인터벌 적용
            let spawnIntervalDecrement = Double(currentWave - 1) * GameBalance.Zombie.spawnIntervalDecrementPerWave
            let adjustedSpawnInterval = max(GameBalance.Zombie.baseSpawnInterval - spawnIntervalDecrement, GameBalance.Zombie.minSpawnInterval)

            if currentTime - lastSpawnTime >= adjustedSpawnInterval && zombies.count < maxZombieCount {
                spawnZombie(currentWave: currentWave)
                lastSpawnTime = currentTime
            }
        }

        updateZombies()
    }

    // 최대 좀비 수 계산 및 업데이트
    private func updateMaxZombieCount(for currentWave: Int) {
        let baseMaxZombies = GameBalance.Zombie.baseMaxZombies
        let additionalZombiesPerWave = GameBalance.Zombie.additionalZombiesPerWave
        let calculatedMax = baseMaxZombies + (currentWave - 1) * additionalZombiesPerWave
        maxZombieCount = min(calculatedMax, GameBalance.Zombie.maxZombieLimit)
    }
    
    private func handleNewWave() {
        lastSpawnTime = 0
        let currentWave = gameStateManager.getCurrentWaveNumber()
        onNewWaveStarted?(currentWave)
    }
    
    private func spawnZombie(currentWave: Int) {
        guard let worldNode = worldNode, let player = player else { return }
        guard zombies.count < maxZombieCount else { return }

        let zombieType = getRandomZombieType()
        let zombie = Zombie(type: zombieType, currentWave: currentWave)
        let spawnPosition = getRandomSpawnPosition()

        zombie.position = spawnPosition
        zombie.setTarget(player)

        // 씬에 추가하고 배열에 추가
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

        // 살아있는 모든 좀비 업데이트
        for zombie in zombies {
            zombie.update()
        }
    }
    
    func removeZombie(_ zombie: Zombie) {
        guard let index = zombies.firstIndex(of: zombie) else {
            zombie.removeFromParent() // 안전하게 노드만 제거
            return
        }

        zombies.remove(at: index)
        zombie.removeFromParent()
    }

    func removeAllZombies() {
        // 안전하게 모든 좀비 제거
        for zombie in zombies {
            zombie.removeFromParent()
        }
        zombies.removeAll()
    }

    // MARK: - Public Getters
    func getZombies() -> [Zombie] {
        return zombies
    }
}
