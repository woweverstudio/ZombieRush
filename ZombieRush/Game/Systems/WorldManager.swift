//
//  WorldManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class WorldManager {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private var mapManager: MapManagerProtocol
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
        self.mapManager = MapManager()
    }
    
    // MARK: - Setup Methods
    func setupWorld() {
        setupMapBackground()
        // 그림자 경계 제거됨 - 그리드 시스템 사용
    }
    
    private func setupMapBackground() {
        guard let worldNode = worldNode else { return }
        mapManager.setupMap(in: worldNode)
    }
    
    // MARK: - Map Management (그리드 기반 간소화)
    func getMapDisplayName() -> String {
        return mapManager.getMapDisplayName()
    }
    
    // MARK: - World Management
    func getWorldNode() -> SKNode? {
        return worldNode
    }
    
    func addChild(_ node: SKNode) {
        worldNode?.addChild(node)
    }
    
    func removeChild(_ node: SKNode) {
        node.removeFromParent()
    }
    
    // 그림자 경계 생성 메서드들 제거됨 - 그리드 시스템 사용
}
