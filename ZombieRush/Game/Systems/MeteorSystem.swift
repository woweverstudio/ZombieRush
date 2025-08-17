import SpriteKit

class MeteorSystem {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private weak var player: Player?
    
    private var isActive: Bool = false
    private var lastMeteorTime: TimeInterval = 0
    private var activeMeteors: [Meteor] = []
    
    // MARK: - Initialization
    init(worldNode: SKNode, player: Player) {
        self.worldNode = worldNode
        self.player = player
    }
    
    // MARK: - Public Methods
    func update(_ currentTime: TimeInterval) {
        guard isActive, let player = player else { return }
        
        // 플레이어가 메테오 모드가 아니면 비활성화
        if !player.getIsMeteorMode() {
            stopMeteorStorm()
            return
        }
        
        // 주기적으로 메테오 생성
        if currentTime - lastMeteorTime >= GameConstants.Items.meteorSpawnInterval {
            spawnMeteor()
            lastMeteorTime = currentTime
        }
        
        // 오래된 메테오 정리
        cleanupOldMeteors()
    }
    
    func startMeteorStorm() {        
        isActive = true
        lastMeteorTime = 0
        
        print("🌠 메테오 스톰 시작!")
        
        // 즉시 첫 번째 메테오 생성
        spawnMeteor()
    }
    
    func stopMeteorStorm() {
        isActive = false
        
        // 활성 메테오들 제거
        activeMeteors.forEach { $0.removeFromParent() }
        activeMeteors.removeAll()
        
        print("🌠 메테오 스톰 종료!")
    }
    
    func getActiveMeteorCount() -> Int {
        return activeMeteors.count
    }
    
    // MARK: - Private Methods
    private func spawnMeteor() {
        guard let worldNode = worldNode, let player = player else { return }
        
        // 플레이어 주변 랜덤 위치 생성 (범위 확대)
        let playerPosition = player.position
        let randomAngle = CGFloat.random(in: 0...(2 * CGFloat.pi))
        let randomDistance = CGFloat.random(in: GameConstants.Items.meteorRadius * 0.1...GameConstants.Items.meteorRadius)
        
        let targetX = playerPosition.x + cos(randomAngle) * randomDistance
        let targetY = playerPosition.y + sin(randomAngle) * randomDistance
        let targetPosition = CGPoint(x: targetX, y: targetY)
        
        // 하늘에서 떨어지는 시작 위치 (화면 위쪽)
        let startPosition = CGPoint(x: targetPosition.x, y: targetPosition.y + 500)
        
        // 메테오 생성
        let meteor = Meteor()
        meteor.position = startPosition
        
        // 월드에 추가
        worldNode.addChild(meteor)
        activeMeteors.append(meteor)
        
        // 낙하 애니메이션
        let fallAction = SKAction.move(to: targetPosition, duration: GameConstants.Items.meteorFallDuration)
        fallAction.timingMode = .easeIn
        meteor.run(fallAction)
    }
    
    private func cleanupOldMeteors() {
        activeMeteors.removeAll { meteor in
            if meteor.parent == nil {
                return true
            }
            return false
        }
    }
    
    // MARK: - Collision Handling
    func handleMeteorCollision(meteor: Meteor, zombie: Zombie) -> Bool {
        // 좀비에게 즉사 데미지
        let isDead = zombie.takeDamage(meteor.getDamage())
        return isDead
    }
}
