//
//  WorldSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class WorldSystem {
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private var mapSystem: MapSystemProtocol
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
        self.mapSystem = MapSystem()
    }
    
    func setupWorld() {
        setupMapBackground()
    }
    
    private func setupMapBackground() {
        guard let worldNode = worldNode else { return }
        mapSystem.setupMap(in: worldNode)
    }
    
    func getMapDisplayName() -> String {
        return mapSystem.getMapDisplayName()
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
