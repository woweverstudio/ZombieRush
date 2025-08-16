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
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
    }
    
    // MARK: - Setup Methods
    func setupWorld() {
        createBackgroundGrid()
        createWorldBorders()
    }
    
    // MARK: - Background Grid Creation
    private func createBackgroundGrid() {
        guard let worldNode = worldNode else { return }
        
        // 간단한 그리드 배경 (선택사항)
        let gridSize: CGFloat = 100
        let gridColor = SKColor.gray.withAlphaComponent(0.3)
        
        // 세로선들
        for x in stride(from: -1000, through: 1000, by: Int(gridSize)) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(x), y: -1000))
            path.addLine(to: CGPoint(x: CGFloat(x), y: 1000))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 1
            worldNode.addChild(line)
        }
        
        // 가로선들
        for y in stride(from: -1000, through: 1000, by: Int(gridSize)) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -1000, y: CGFloat(y)))
            path.addLine(to: CGPoint(x: 1000, y: CGFloat(y)))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 1
            worldNode.addChild(line)
        }
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
    
    // MARK: - Border Creation
    private func createWorldBorders() {
        guard let worldNode = worldNode else { return }
        
        let worldWidth = GameConstants.Physics.worldWidth
        let worldHeight = GameConstants.Physics.worldHeight
        let borderWidth = GameConstants.WorldBorder.borderWidth
        let borderColor = SKColor.red.withAlphaComponent(GameConstants.WorldBorder.borderAlpha)
        
        // 상단 경계
        let topBorder = createBorderNode(rect: CGRect(x: -worldWidth/2, y: worldHeight/2 - borderWidth, width: worldWidth, height: borderWidth), color: borderColor)
        worldNode.addChild(topBorder)
        
        // 하단 경계
        let bottomBorder = createBorderNode(rect: CGRect(x: -worldWidth/2, y: -worldHeight/2, width: worldWidth, height: borderWidth), color: borderColor)
        worldNode.addChild(bottomBorder)
        
        // 좌측 경계
        let leftBorder = createBorderNode(rect: CGRect(x: -worldWidth/2, y: -worldHeight/2, width: borderWidth, height: worldHeight), color: borderColor)
        worldNode.addChild(leftBorder)
        
        // 우측 경계
        let rightBorder = createBorderNode(rect: CGRect(x: worldWidth/2 - borderWidth, y: -worldHeight/2, width: borderWidth, height: worldHeight), color: borderColor)
        worldNode.addChild(rightBorder)
    }
    
    private func createBorderNode(rect: CGRect, color: SKColor) -> SKShapeNode {
        let border = SKShapeNode(rect: rect)
        border.fillColor = color
        border.strokeColor = SKColor.red
        border.lineWidth = GameConstants.WorldBorder.lineWidth
        return border
    }
}
