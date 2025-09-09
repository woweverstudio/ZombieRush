//
//  MapSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

// MARK: - Map System Protocol (그리드 기반 간소화)
protocol MapSystemProtocol {
    func setupMap(in worldNode: SKNode)
    func getMapDisplayName() -> String
}

// MARK: - Map System Implementation
class MapSystem: MapSystemProtocol {
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    func setupMap(in worldNode: SKNode) {
        createMapBackground(in: worldNode)
    }
    
    private func createMapBackground(in worldNode: SKNode) {
        removeCurrentMap()
        createGridBackground(in: worldNode)
    }
    
    private func createGridBackground(in worldNode: SKNode) {
        let worldWidth = GameBalance.Physics.worldWidth
        let worldHeight = GameBalance.Physics.worldHeight
        let gridSize = UIConstants.Map.gridSpacing
        
        // 배경 생성
        createBackground(in: worldNode, width: worldWidth, height: worldHeight)
        
        // 그리드 라인 생성
        createGridLines(in: worldNode, width: worldWidth, height: worldHeight, gridSize: gridSize)
        
        // 경계선 생성
        createBorders(in: worldNode, width: worldWidth, height: worldHeight)
    }
    
    private func createBackground(in worldNode: SKNode, width: CGFloat, height: CGFloat) {
        let backgroundRect = SKShapeNode(rect: CGRect(
            x: -width/2, y: -height/2, width: width, height: height
        ))
        backgroundRect.fillColor = UIConstants.Colors.Neon.cyberpunkBackgroundColor
        backgroundRect.strokeColor = .clear
        backgroundRect.zPosition = UIConstants.Map.backgroundZPosition
        backgroundRect.name = TextConstants.NodeNames.cyberpunkBackground
        worldNode.addChild(backgroundRect)
    }
    
    private func createGridLines(in worldNode: SKNode, width: CGFloat, height: CGFloat, gridSize: CGFloat) {
        createVerticalGridLines(in: worldNode, width: width, height: height, gridSize: gridSize)
        createHorizontalGridLines(in: worldNode, width: width, height: height, gridSize: gridSize)
    }
    
    private func createVerticalGridLines(in worldNode: SKNode, width: CGFloat, height: CGFloat, gridSize: CGFloat) {
        let lineCount = Int(width / gridSize)
        for i in 0...lineCount {
            let x = -width/2 + CGFloat(i) * gridSize
            if x > width/2 { continue }
            
            let line = createNeonGridLine(from: CGPoint(x: x, y: -height/2),
                                          to: CGPoint(x: x, y: height/2))
            line.name = "NeonGridLineVertical_\(i)"
            worldNode.addChild(line)
        }
    }
    
    private func createHorizontalGridLines(in worldNode: SKNode, width: CGFloat, height: CGFloat, gridSize: CGFloat) {
        let lineCount = Int(height / gridSize)
        for i in 0...lineCount {
            let y = -height/2 + CGFloat(i) * gridSize
            if y > height/2 { continue }
            
            let line = createNeonGridLine(from: CGPoint(x: -width/2, y: y),
                                          to: CGPoint(x: width/2, y: y))
            line.name = "NeonGridLineHorizontal_\(i)"
            worldNode.addChild(line)
        }
    }
    
    private func createNeonGridLine(from startPoint: CGPoint, to endPoint: CGPoint) -> SKShapeNode {
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        line.path = path
        line.strokeColor = UIConstants.Colors.Neon.gridColor
        line.lineWidth = UIConstants.Map.gridLineWidth
        line.zPosition = UIConstants.Map.gridZPosition
        return line
    }
    
    private func createBorders(in worldNode: SKNode, width: CGFloat, height: CGFloat) {
        // 메인 경계선
        let borderRect = SKShapeNode(rect: CGRect(x: -width/2, y: -height/2, width: width, height: height))
        borderRect.fillColor = .clear
        borderRect.strokeColor = UIConstants.Colors.Neon.borderColor
        borderRect.lineWidth = UIConstants.Map.borderLineWidth
        borderRect.zPosition = UIConstants.Map.borderZPosition
        borderRect.name = TextConstants.NodeNames.neonBorder
        worldNode.addChild(borderRect)
        
        // 글로우 효과를 위한 외부 경계선
        let outerBorderRect = SKShapeNode(rect: CGRect(
            x: -width/2 - 3, y: -height/2 - 3, width: width + 6, height: height + 6
        ))
        outerBorderRect.fillColor = .clear
        outerBorderRect.strokeColor = UIConstants.Colors.Neon.borderGlowColor
        outerBorderRect.lineWidth = 2
        outerBorderRect.zPosition = UIConstants.Map.backgroundZPosition + 1
        outerBorderRect.name = TextConstants.NodeNames.neonBorderGlow
        worldNode.addChild(outerBorderRect)
    }
    
    private func removeCurrentMap() {
        // TODO: 기존 그리드 노드들 제거 로직 구현 필요 시
    }
    
    func getMapDisplayName() -> String {
        return "네온 그리드"
    }
}
