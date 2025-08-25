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
    
    // MARK: - Properties
    // 그리드 기반으로 변경되어 단순화됨
    
    // MARK: - Initialization
    init() {
        // 그리드 기반으로 초기화 단순화
    }
    
    // MARK: - Public Methods
    func setupMap(in worldNode: SKNode) {
        createMapBackground(in: worldNode)
    }
    
    // MARK: - Private Methods
    private func createMapBackground(in worldNode: SKNode) {
        // 기존 배경 제거 (있다면)
        removeCurrentMap()
        
        // 단순한 그리드 배경 생성 (이미지 대신)
        createGridBackground(in: worldNode)
    }
    
    // MARK: - Cyberpunk Grid Background Creation
    private func createGridBackground(in worldNode: SKNode) {
        let worldWidth = GameBalance.Physics.worldWidth
        let worldHeight = GameBalance.Physics.worldHeight
        let gridSize = UIConstants.Map.gridSpacing
        
        // 사이버펑크 어두운 배경색 생성
        let backgroundRect = SKShapeNode(rect: CGRect(
            x: -worldWidth/2, 
            y: -worldHeight/2, 
            width: worldWidth, 
            height: worldHeight
        ))
        backgroundRect.fillColor = UIConstants.Colors.Neon.cyberpunkBackgroundColor
        backgroundRect.strokeColor = .clear
        backgroundRect.zPosition = UIConstants.Map.backgroundZPosition
        backgroundRect.name = "CyberpunkBackground"
        worldNode.addChild(backgroundRect)
        
        // 네온 수직 그리드 라인
        let verticalLineCount = Int(worldWidth / gridSize)
        for i in 0...verticalLineCount {
            let x = -worldWidth/2 + CGFloat(i) * gridSize
            // 맵 경계를 넘지 않도록 체크
            if x > worldWidth/2 { continue }
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: -worldHeight/2))
            path.addLine(to: CGPoint(x: x, y: worldHeight/2))
            line.path = path
            line.strokeColor = UIConstants.Colors.Neon.gridColor
            line.lineWidth = UIConstants.Map.gridLineWidth
            line.zPosition = UIConstants.Map.gridZPosition
            line.name = "NeonGridLineVertical_\(i)"
            

            
            worldNode.addChild(line)
        }
        
        // 네온 수평 그리드 라인
        let horizontalLineCount = Int(worldHeight / gridSize)
        for i in 0...horizontalLineCount {
            let y = -worldHeight/2 + CGFloat(i) * gridSize
            // 맵 경계를 넘지 않도록 체크
            if y > worldHeight/2 { continue }
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -worldWidth/2, y: y))
            path.addLine(to: CGPoint(x: worldWidth/2, y: y))
            line.path = path
            line.strokeColor = UIConstants.Colors.Neon.gridColor
            line.lineWidth = UIConstants.Map.gridLineWidth
            line.zPosition = UIConstants.Map.gridZPosition
            line.name = "NeonGridLineHorizontal_\(i)"
            

            
            worldNode.addChild(line)
        }
        
        // 네온 경계선 (사이버펑크 스타일)
        let borderRect = SKShapeNode(rect: CGRect(
            x: -worldWidth/2, 
            y: -worldHeight/2, 
            width: worldWidth, 
            height: worldHeight
        ))
        borderRect.fillColor = .clear
        borderRect.strokeColor = UIConstants.Colors.Neon.borderColor
        borderRect.lineWidth = UIConstants.Map.borderLineWidth
        borderRect.glowWidth = UIConstants.Colors.Neon.borderGlowWidth  // 진짜 네온 글로우!
        borderRect.zPosition = UIConstants.Map.borderZPosition
        borderRect.name = "NeonBorder"
        

        
        worldNode.addChild(borderRect)
        
        // 추가 글로우 효과를 위한 더 큰 경계선
        let outerBorderRect = SKShapeNode(rect: CGRect(
            x: -worldWidth/2 - 3, 
            y: -worldHeight/2 - 3, 
            width: worldWidth + 6, 
            height: worldHeight + 6
        ))
        outerBorderRect.fillColor = .clear
        outerBorderRect.strokeColor = UIConstants.Colors.Neon.borderGlowColor
        outerBorderRect.lineWidth = 2
        outerBorderRect.zPosition = UIConstants.Map.backgroundZPosition + 1
        outerBorderRect.name = "NeonBorderGlow"
        

        
        worldNode.addChild(outerBorderRect)
    }
    
    private func removeCurrentMap() {
        // 기존 그리드 노드들 제거
    }
    
    func getMapDisplayName() -> String {
        return "네온 그리드"
    }
}
