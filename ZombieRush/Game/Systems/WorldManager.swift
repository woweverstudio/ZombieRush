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
    
    func setupWorld() {
        setupMapBackground()
    }
    
    private func setupMapBackground() {
        guard let worldNode = worldNode else { return }
        mapManager.setupMap(in: worldNode)
    }
    
    func getMapDisplayName() -> String {
        return mapManager.getMapDisplayName()
    }
    
    func getWorldNode() -> SKNode? {
        return worldNode
    }
    
    func addChild(_ node: SKNode) {
        worldNode?.addChild(node)
    }
    
    func removeChild(_ node: SKNode) {
        node.removeFromParent()
    }
}
