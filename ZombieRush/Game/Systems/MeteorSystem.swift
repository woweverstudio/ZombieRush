import SpriteKit

class MeteorSystem {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private var activeMeteors: [Meteor] = []
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
    }
    
    // MARK: - Public Methods
    func deployMeteor(at position: CGPoint) {
        guard let worldNode = worldNode else { return }
        
        // 메테오 생성 및 배치 (소리는 폭발할 때 재생)
        let meteor = Meteor(at: position)
        worldNode.addChild(meteor)
        activeMeteors.append(meteor)
    }
    
    func update(_ currentTime: TimeInterval) {
        // 폭발한 메테오 정리
        cleanupExplodedMeteors()
    }
    
    func getActiveMeteorCount() -> Int {
        return activeMeteors.count
    }
    
    func clearAllMeteors() {
        // 모든 활성 메테오 제거
        activeMeteors.forEach { $0.removeFromParent() }
        activeMeteors.removeAll()
    }
    
    // MARK: - Private Methods
    private func cleanupExplodedMeteors() {
        activeMeteors.removeAll { meteor in
            // 부모에서 제거되었거나 이미 폭발한 메테오 제거
            if meteor.parent == nil || meteor.getHasExploded() {
                return true
            }
            return false
        }
    }
    

}