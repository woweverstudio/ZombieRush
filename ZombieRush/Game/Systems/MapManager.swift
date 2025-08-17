//
//  MapManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

// MARK: - Map Manager Protocol (확장성을 위한 인터페이스)
protocol MapManagerProtocol {
    func setupMap(in worldNode: SKNode, mapType: GameConstants.Map.MapType)
    func setupMap(in worldNode: SKNode)
    func getCurrentMapType() -> GameConstants.Map.MapType
    func changeMap(to mapType: GameConstants.Map.MapType, in worldNode: SKNode)
    func getMapDisplayName() -> String
    func getMapImageName() -> String
}

// MARK: - Map Manager Implementation
class MapManager: MapManagerProtocol {
    
    // MARK: - Properties
    private var currentMapType: GameConstants.Map.MapType
    private weak var backgroundNode: SKSpriteNode?
    private var boundaryNodes: [SKSpriteNode] = []
    
    // MARK: - Initialization
    init(mapType: GameConstants.Map.MapType = .jungle) {
        self.currentMapType = mapType
    }
    
    // MARK: - Public Methods
    func setupMap(in worldNode: SKNode, mapType: GameConstants.Map.MapType) {
        self.currentMapType = mapType
        createMapBackground(in: worldNode)
    }
    
    func setupMap(in worldNode: SKNode) {
        createMapBackground(in: worldNode)
    }
    
    func getCurrentMapType() -> GameConstants.Map.MapType {
        return currentMapType
    }
    
    func changeMap(to mapType: GameConstants.Map.MapType, in worldNode: SKNode) {
        // 기존 맵 제거
        removeCurrentMap()
        
        // 새 맵 설정
        self.currentMapType = mapType
        createMapBackground(in: worldNode)
    }
    
    // MARK: - Private Methods
    private func createMapBackground(in worldNode: SKNode) {
        // 기존 배경 제거 (있다면)
        removeCurrentMap()
        
        // 1. 경계 이미지 생성 (맵보다 먼저)
        createMapBoundaries(in: worldNode)
        
        // 2. 맵 이미지 생성 (텍스처 캐시 사용)
        let mapImageName = currentMapType.imageName
        let backgroundSprite: SKSpriteNode
        
        if let cachedTexture = TextureCache.shared.getTexture(named: mapImageName) {
            backgroundSprite = SKSpriteNode(texture: cachedTexture)
        } else {
            backgroundSprite = SKSpriteNode(imageNamed: mapImageName)
        }
        
        // 월드 크기에 정확히 맞춤
        let worldSize = CGSize(
            width: GameConstants.Physics.worldWidth,
            height: GameConstants.Physics.worldHeight
        )
        
        // 원본 이미지 크기 확인 (디버그용)
        let originalSize = backgroundSprite.texture?.size() ?? CGSize.zero
        print("🗺️ 원본 이미지 크기: \(originalSize)")
        print("🗺️ 월드 크기: \(worldSize)")
        
        // 맵 크기를 게임 월드 크기에 정확히 맞춤
        backgroundSprite.size = worldSize
        
        // 위치 및 z-position 설정
        backgroundSprite.position = CGPoint(x: 0, y: 0)
        backgroundSprite.zPosition = GameConstants.Map.backgroundZPosition
        backgroundSprite.name = "MapBackground"
        
        // 이미지 품질 향상을 위한 설정
        backgroundSprite.texture?.filteringMode = .linear
        
        // 월드 노드에 추가
        worldNode.addChild(backgroundSprite)
        
        // 참조 저장
        self.backgroundNode = backgroundSprite
        
        print("🗺️ 맵 배경 생성 완료: \(currentMapType.displayName)")
        print("🗺️ 최종 크기: \(worldSize)")
    }
    
    // MARK: - Map Boundary Creation
    private func createMapBoundaries(in worldNode: SKNode) {
        if GameConstants.Map.useTiledBoundary {
            createTiledBoundaries(in: worldNode)
        } else {
            createStretchedBoundaries(in: worldNode)
        }
    }
    
    // MARK: - Tiled Boundary Creation (원본 크기 유지)
    private func createTiledBoundaries(in worldNode: SKNode) {
        let worldWidth = GameConstants.Physics.worldWidth
        let worldHeight = GameConstants.Physics.worldHeight
        let boundaryThickness = GameConstants.Map.boundaryThickness
        let overflow = GameConstants.Map.boundaryOverflow
        let boundaryImageName = GameConstants.Map.boundaryImageName
        
        // 원본 이미지 크기 확인 (텍스처 캐시 사용)
        let sampleSprite: SKSpriteNode
        if let cachedTexture = TextureCache.shared.getTexture(named: boundaryImageName) {
            sampleSprite = SKSpriteNode(texture: cachedTexture)
        } else {
            sampleSprite = SKSpriteNode(imageNamed: boundaryImageName)
        }
        let originalTileSize = sampleSprite.texture?.size() ?? CGSize(width: GameConstants.Map.defaultTileSize, height: GameConstants.Map.defaultTileSize)
        
        print("🧱 경계 타일 원본 크기: \(originalTileSize)")
        
        // 상단 경계 타일링
        createTiledBoundaryStrip(
            in: worldNode,
            imageName: boundaryImageName,
            tileSize: originalTileSize,
            stripRect: CGRect(
                x: -worldWidth/2 - overflow,
                y: worldHeight/2,
                width: worldWidth + (overflow * 2),
                height: boundaryThickness
            ),
            namePrefix: "TopBoundary"
        )
        
        // 하단 경계 타일링
        createTiledBoundaryStrip(
            in: worldNode,
            imageName: boundaryImageName,
            tileSize: originalTileSize,
            stripRect: CGRect(
                x: -worldWidth/2 - overflow,
                y: -worldHeight/2 - boundaryThickness,
                width: worldWidth + (overflow * 2),
                height: boundaryThickness
            ),
            namePrefix: "BottomBoundary"
        )
        
        // 좌측 경계 타일링
        createTiledBoundaryStrip(
            in: worldNode,
            imageName: boundaryImageName,
            tileSize: originalTileSize,
            stripRect: CGRect(
                x: -worldWidth/2 - boundaryThickness,
                y: -worldHeight/2,
                width: boundaryThickness,
                height: worldHeight
            ),
            namePrefix: "LeftBoundary"
        )
        
        // 우측 경계 타일링
        createTiledBoundaryStrip(
            in: worldNode,
            imageName: boundaryImageName,
            tileSize: originalTileSize,
            stripRect: CGRect(
                x: worldWidth/2,
                y: -worldHeight/2,
                width: boundaryThickness,
                height: worldHeight
            ),
            namePrefix: "RightBoundary"
        )
        
        // 4개 모서리 타일링
        let cornerRects = [
            CGRect(x: -worldWidth/2 - boundaryThickness, y: worldHeight/2, width: boundaryThickness, height: boundaryThickness), // 좌상단
            CGRect(x: worldWidth/2, y: worldHeight/2, width: boundaryThickness, height: boundaryThickness), // 우상단
            CGRect(x: -worldWidth/2 - boundaryThickness, y: -worldHeight/2 - boundaryThickness, width: boundaryThickness, height: boundaryThickness), // 좌하단
            CGRect(x: worldWidth/2, y: -worldHeight/2 - boundaryThickness, width: boundaryThickness, height: boundaryThickness) // 우하단
        ]
        
        let cornerNames = ["TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner"]
        
        for (index, cornerRect) in cornerRects.enumerated() {
            createTiledBoundaryStrip(
                in: worldNode,
                imageName: boundaryImageName,
                tileSize: originalTileSize,
                stripRect: cornerRect,
                namePrefix: cornerNames[index]
            )
        }
        
        print("🗺️ 타일링 맵 경계 생성 완료: \(boundaryNodes.count)개 타일")
    }
    
    // MARK: - Tiled Strip Creation
    private func createTiledBoundaryStrip(in worldNode: SKNode, imageName: String, tileSize: CGSize, stripRect: CGRect, namePrefix: String) {
        let tilesX = Int(ceil(stripRect.width / tileSize.width))
        let tilesY = Int(ceil(stripRect.height / tileSize.height))
        
        for x in 0..<tilesX {
            for y in 0..<tilesY {
                let tileX = stripRect.minX + (CGFloat(x) * tileSize.width) + (tileSize.width / 2)
                let tileY = stripRect.minY + (CGFloat(y) * tileSize.height) + (tileSize.height / 2)
                
                let tile = SKSpriteNode(imageNamed: imageName)
                tile.size = tileSize  // 원본 크기 유지
                tile.position = CGPoint(x: tileX, y: tileY)
                tile.zPosition = GameConstants.Map.boundaryZPosition
                tile.name = "\(namePrefix)_\(x)_\(y)"
                tile.texture?.filteringMode = .linear
                
                worldNode.addChild(tile)
                boundaryNodes.append(tile)
            }
        }
    }
    
    // MARK: - Stretched Boundary Creation (기존 방식)
    private func createStretchedBoundaries(in worldNode: SKNode) {
        let worldWidth = GameConstants.Physics.worldWidth
        let worldHeight = GameConstants.Physics.worldHeight
        let boundaryThickness = GameConstants.Map.boundaryThickness
        let overflow = GameConstants.Map.boundaryOverflow
        
        // 경계 이미지 이름
        let boundaryImageName = GameConstants.Map.boundaryImageName
        
        // 상단 경계
        let topBoundary = createBoundaryNode(
            imageName: boundaryImageName,
            size: CGSize(width: worldWidth + (overflow * 2), height: boundaryThickness),
            position: CGPoint(x: 0, y: worldHeight/2 + boundaryThickness/2),
            name: "TopBoundary"
        )
        
        // 하단 경계
        let bottomBoundary = createBoundaryNode(
            imageName: boundaryImageName,
            size: CGSize(width: worldWidth + (overflow * 2), height: boundaryThickness),
            position: CGPoint(x: 0, y: -worldHeight/2 - boundaryThickness/2),
            name: "BottomBoundary"
        )
        
        // 좌측 경계 (상하 경계와 겹치지 않도록)
        let leftBoundary = createBoundaryNode(
            imageName: boundaryImageName,
            size: CGSize(width: boundaryThickness, height: worldHeight),
            position: CGPoint(x: -worldWidth/2 - boundaryThickness/2, y: 0),
            name: "LeftBoundary"
        )
        
        // 우측 경계 (상하 경계와 겹치지 않도록)
        let rightBoundary = createBoundaryNode(
            imageName: boundaryImageName,
            size: CGSize(width: boundaryThickness, height: worldHeight),
            position: CGPoint(x: worldWidth/2 + boundaryThickness/2, y: 0),
            name: "RightBoundary"
        )
        
        // 모서리 경계 (4개 모서리 채우기)
        let cornerSize = CGSize(width: boundaryThickness, height: boundaryThickness)
        
        // 좌상단 모서리
        let topLeftCorner = createBoundaryNode(
            imageName: boundaryImageName,
            size: cornerSize,
            position: CGPoint(x: -worldWidth/2 - boundaryThickness/2, y: worldHeight/2 + boundaryThickness/2),
            name: "TopLeftCorner"
        )
        
        // 우상단 모서리
        let topRightCorner = createBoundaryNode(
            imageName: boundaryImageName,
            size: cornerSize,
            position: CGPoint(x: worldWidth/2 + boundaryThickness/2, y: worldHeight/2 + boundaryThickness/2),
            name: "TopRightCorner"
        )
        
        // 좌하단 모서리
        let bottomLeftCorner = createBoundaryNode(
            imageName: boundaryImageName,
            size: cornerSize,
            position: CGPoint(x: -worldWidth/2 - boundaryThickness/2, y: -worldHeight/2 - boundaryThickness/2),
            name: "BottomLeftCorner"
        )
        
        // 우하단 모서리
        let bottomRightCorner = createBoundaryNode(
            imageName: boundaryImageName,
            size: cornerSize,
            position: CGPoint(x: worldWidth/2 + boundaryThickness/2, y: -worldHeight/2 - boundaryThickness/2),
            name: "BottomRightCorner"
        )
        
        // 모든 경계 노드를 배열에 저장
        boundaryNodes = [topBoundary, bottomBoundary, leftBoundary, rightBoundary,
                        topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner]
        
        // 월드에 추가
        boundaryNodes.forEach { worldNode.addChild($0) }
        
        print("🗺️ 스트레치 맵 경계 생성 완료: \(boundaryNodes.count)개 경계 노드")
    }
    
    private func createBoundaryNode(imageName: String, size: CGSize, position: CGPoint, name: String) -> SKSpriteNode {
        let boundaryNode: SKSpriteNode
        
        // 텍스처 캐시 사용
        if let cachedTexture = TextureCache.shared.getTexture(named: imageName) {
            boundaryNode = SKSpriteNode(texture: cachedTexture)
        } else {
            boundaryNode = SKSpriteNode(imageNamed: imageName)
        }
        
        boundaryNode.size = size
        boundaryNode.position = position
        boundaryNode.zPosition = GameConstants.Map.boundaryZPosition
        boundaryNode.name = name
        boundaryNode.texture?.filteringMode = .linear
        return boundaryNode
    }
    
    private func removeCurrentMap() {
        // 맵 배경 제거
        backgroundNode?.removeFromParent()
        backgroundNode = nil
        
        // 경계 노드들 제거
        boundaryNodes.forEach { $0.removeFromParent() }
        boundaryNodes.removeAll()
    }
    
    // MARK: - Map Information
    func getMapDisplayName() -> String {
        return currentMapType.displayName
    }
    
    func getMapImageName() -> String {
        return currentMapType.imageName
    }
    
    // MARK: - Future Extension Methods
    // 향후 맵 타일링, 맵 애니메이션 등을 위한 확장 포인트
    private func createTiledMap(in worldNode: SKNode) {
        // 향후 큰 맵을 위한 타일링 시스템 구현 예정
    }
    
    private func preloadMapAssets() {
        // 향후 맵 에셋 사전 로딩을 위한 메서드
    }
}
