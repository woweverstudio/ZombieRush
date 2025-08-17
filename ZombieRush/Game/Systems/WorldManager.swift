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
    init(worldNode: SKNode, mapType: GameConstants.Map.MapType = .jungle) {
        self.worldNode = worldNode
        self.mapManager = MapManager(mapType: mapType)
    }
    
    // MARK: - Setup Methods
    func setupWorld() {
        setupMapBackground()
        createShadowBorders()
    }
    
    private func setupMapBackground() {
        guard let worldNode = worldNode else { return }
        mapManager.setupMap(in: worldNode)
    }
    
    // MARK: - Map Management
    func changeMap(to mapType: GameConstants.Map.MapType) {
        guard let worldNode = worldNode else { return }
        mapManager.changeMap(to: mapType, in: worldNode)
    }
    
    func getCurrentMapType() -> GameConstants.Map.MapType {
        return mapManager.getCurrentMapType()
    }
    
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
    
    // MARK: - Shadow Border Creation (그림자 효과)
    private func createShadowBorders() {
        guard let worldNode = worldNode else { return }
        
        let worldWidth = GameConstants.Physics.worldWidth
        let worldHeight = GameConstants.Physics.worldHeight
        let borderWidth = GameConstants.WorldBorder.borderWidth
        let borderColor = GameConstants.WorldBorder.shadowColor.withAlphaComponent(GameConstants.WorldBorder.borderAlpha)
        
        // 상단 그림자 경계 (맵 안쪽)
        let topBorder = createShadowBorderNode(
            rect: CGRect(x: -worldWidth/2, y: worldHeight/2 - borderWidth, width: worldWidth, height: borderWidth),
            color: borderColor
        )
        worldNode.addChild(topBorder)
        
        // 하단 그림자 경계 (맵 안쪽)
        let bottomBorder = createShadowBorderNode(
            rect: CGRect(x: -worldWidth/2, y: -worldHeight/2, width: worldWidth, height: borderWidth),
            color: borderColor
        )
        worldNode.addChild(bottomBorder)
        
        // 좌측 그림자 경계 (맵 안쪽)
        let leftBorder = createShadowBorderNode(
            rect: CGRect(x: -worldWidth/2, y: -worldHeight/2, width: borderWidth, height: worldHeight),
            color: borderColor
        )
        worldNode.addChild(leftBorder)
        
        // 우측 그림자 경계 (맵 안쪽)
        let rightBorder = createShadowBorderNode(
            rect: CGRect(x: worldWidth/2 - borderWidth, y: -worldHeight/2, width: borderWidth, height: worldHeight),
            color: borderColor
        )
        worldNode.addChild(rightBorder)
        
        print("🌫️ 그림자 경계 생성 완료: 얇은 검은색 테두리")
    }
    
    private func createShadowBorderNode(rect: CGRect, color: SKColor) -> SKShapeNode {
        let border = SKShapeNode(rect: rect)
        border.fillColor = color
        border.strokeColor = color.withAlphaComponent(0.9)  // 테두리를 더 진하게 (0.6 → 0.9)
        border.lineWidth = GameConstants.WorldBorder.lineWidth
        border.zPosition = GameConstants.Map.backgroundZPosition + 10  // 맵 위, 게임 오브젝트 아래
        border.name = "ShadowBorder"
        return border
    }
}
