//
//  TextureCache.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class TextureCache {
    static let shared = TextureCache()
    
    private init() {}
    
    // MARK: - Cache Storage
    private var textureCache: [String: SKTexture] = [:]
    private var preloadedTextures: Set<String> = []
    
    // MARK: - Public Methods
    
    /**
     텍스처를 캐시에서 가져오거나 새로 로드합니다.
     - Parameter imageName: 이미지 이름
     - Returns: SKTexture 또는 nil (로드 실패 시)
     */
    func getTexture(named imageName: String) -> SKTexture? {
        // 캐시에서 먼저 확인
        if let cachedTexture = textureCache[imageName] {
            return cachedTexture
        }
        
        // 캐시에 없으면 새로 로드
        if let texture = loadTexture(named: imageName) {
            textureCache[imageName] = texture
            return texture
        }
        
        return nil
    }
    
    /**
     게임 시작 시 자주 사용되는 텍스처들을 미리 로드합니다.
     */
    func preloadGameTextures() {
        let texturesToPreload = [
            // 플레이어 이미지
            GameConstants.Player.leftImageName,
            GameConstants.Player.rightImageName,
            
            // 좀비 이미지
            GameConstants.Zombie.normalLeftImage,
            GameConstants.Zombie.normalRightImage,
            GameConstants.Zombie.fastLeftImage,
            GameConstants.Zombie.fastRightImage,
            GameConstants.Zombie.strongLeftImage,
            GameConstants.Zombie.strongRightImage,
            
            // 맵 이미지
            GameConstants.Map.defaultMapName,
            GameConstants.Map.boundaryImageName,
            
            // 아이템 이미지
            GameConstants.Items.speedBoostImageName,
            GameConstants.Items.healthRestoreImageName,
            GameConstants.Items.ammoRestoreImageName,
            GameConstants.Items.invincibilityImageName,
            GameConstants.Items.shotgunImageName,
            GameConstants.Items.meteorImageName
        ]
        
        for textureName in texturesToPreload {
            if !preloadedTextures.contains(textureName) {
                if let texture = loadTexture(named: textureName) {
                    textureCache[textureName] = texture
                    preloadedTextures.insert(textureName)
                    print("✅ 텍스처 프리로드 성공: \(textureName)")
                } else {
                    print("⚠️ 텍스처 프리로드 실패: \(textureName)")
                }
            }
        }
        
        print("📦 텍스처 프리로드 완료: \(preloadedTextures.count)개")
    }
    
    /**
     특정 텍스처를 캐시에서 제거합니다.
     - Parameter imageName: 제거할 이미지 이름
     */
    func removeTexture(named imageName: String) {
        textureCache.removeValue(forKey: imageName)
        preloadedTextures.remove(imageName)
    }
    
    /**
     모든 캐시를 정리합니다.
     */
    func clearCache() {
        textureCache.removeAll()
        preloadedTextures.removeAll()
        print("🗑️ 텍스처 캐시 정리 완료")
    }
    
    /**
     현재 캐시 상태를 반환합니다.
     */
    func getCacheInfo() -> String {
        let cacheSize = textureCache.count
        let preloadedSize = preloadedTextures.count
        
        return """
        === 텍스처 캐시 정보 ===
        캐시된 텍스처: \(cacheSize)개
        프리로드된 텍스처: \(preloadedSize)개
        ====================
        """
    }
    
    // MARK: - Private Methods
    private func loadTexture(named imageName: String) -> SKTexture? {
        // UIImage를 통해 안전하게 로드
        guard let image = UIImage(named: imageName) else {
            return nil
        }
        
        let texture = SKTexture(image: image)
        
        // 텍스처 필터링 모드 설정 (성능 최적화)
        texture.filteringMode = .linear
        
        return texture
    }
}
