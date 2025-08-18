//
//  HUDManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class HUDManager {
    
    // MARK: - Properties
    private weak var camera: SKCameraNode?
    private var hudNode: SKNode?
    
    // MARK: - UI Elements
    private var scoreLabel: SKLabelNode?
    private var timeLabel: SKLabelNode?
    private var healthBar: SKShapeNode?
    private var healthBarFill: SKShapeNode?
    private var ammoBar: SKShapeNode?
    private var ammoBarFill: SKShapeNode?
    private var reloadLabel: SKLabelNode?
    
    // MARK: - Game Data
    private(set) var score: Int = 0
    private let gameStateManager = GameStateManager.shared
    
    // MARK: - Initialization
    init(camera: SKCameraNode) {
        self.camera = camera
        setupHUD()
    }
    
    // MARK: - Setup
    private func setupHUD() {
        guard let camera = camera else { return }
        
        hudNode = SKNode()
        hudNode?.name = "HUD"
        hudNode?.zPosition = 200
        camera.addChild(hudNode!)
        
        setupScoreLabel()
        setupTimeLabel()
        setupHealthBar()
        setupAmmoBar()
    }
    
    private func setupScoreLabel() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        scoreLabel = SKLabelNode(text: "SCORE: 0")
        scoreLabel?.fontName = "Arial-Bold"
        scoreLabel?.fontSize = 20
        scoreLabel?.fontColor = SKColor.white.withAlphaComponent(0.9)
        scoreLabel?.position = CGPoint(x: -screenWidth/2 + 80, y: screenHeight/2 - 50)
        scoreLabel?.horizontalAlignmentMode = .left
        
        // 배경 없이 심플하게
        hudNode?.addChild(scoreLabel!)
    }
    
    private func setupTimeLabel() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        timeLabel = SKLabelNode(text: "00:00")
        timeLabel?.fontName = "Arial-Bold"
        timeLabel?.fontSize = 20
        timeLabel?.fontColor = SKColor.white.withAlphaComponent(0.9)
        timeLabel?.position = CGPoint(x: screenWidth/2 - 80, y: screenHeight/2 - 50)
        timeLabel?.horizontalAlignmentMode = .right
        
        // 배경 없이 심플하게
        hudNode?.addChild(timeLabel!)
    }
    
    private func setupHealthBar() {
        let screenHeight = UIScreen.main.bounds.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 20
        let barY = -screenHeight/2 + 60
        
        // 체력 바 배경 (심플한 네온 스타일)
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        healthBar?.fillColor = SKColor.clear
        healthBar?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        healthBar?.lineWidth = 1
        healthBar?.position = CGPoint(x: -barWidth/2, y: barY)
        hudNode?.addChild(healthBar!)
        
        // 체력 바 채우기 (네온 그린)
        healthBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        healthBarFill?.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)
        healthBarFill?.strokeColor = SKColor.clear
        healthBarFill?.position = CGPoint(x: 0, y: 0)
        healthBar?.addChild(healthBarFill!)
        
        // 체력 라벨 (바 중앙 정렬)
        let healthLabel = SKLabelNode(text: "HP")
        healthLabel.fontName = "Arial-Bold"
        healthLabel.fontSize = 14
        healthLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        healthLabel.position = CGPoint(x: 0, y: -6)
        healthLabel.horizontalAlignmentMode = .center
        healthBar?.addChild(healthLabel)
    }
    
    private func setupAmmoBar() {    
        let screenHeight = UIScreen.main.bounds.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 20
        let barY = -screenHeight/2 + 30
        
        // 탄약 바 배경 (심플한 네온 스타일)
        ammoBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        ammoBar?.fillColor = SKColor.clear
        ammoBar?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        ammoBar?.lineWidth = 1
        ammoBar?.position = CGPoint(x: -barWidth/2, y: barY)
        hudNode?.addChild(ammoBar!)
        
        // 탄약 바 채우기 (네온 시안)
        ammoBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        ammoBarFill?.fillColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8)
        ammoBarFill?.strokeColor = SKColor.clear
        ammoBarFill?.position = CGPoint(x: 0, y: 0)
        ammoBar?.addChild(ammoBarFill!)
        
        // 탄약 라벨 (바 중앙 정렬)
        let ammoLabel = SKLabelNode(text: "AMMO")
        ammoLabel.fontName = "Arial-Bold"
        ammoLabel.fontSize = 14
        ammoLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        ammoLabel.position = CGPoint(x: 0, y: -6)
        ammoLabel.horizontalAlignmentMode = .center
        ammoBar?.addChild(ammoLabel)
        
        // 재장전 라벨 (네온 스타일)
        reloadLabel = SKLabelNode(text: "RELOADING...")
        reloadLabel?.fontName = "Arial-Bold"
        reloadLabel?.fontSize = 16
        reloadLabel?.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        reloadLabel?.position = CGPoint(x: barWidth/2 + 70, y: barY - 6)
        reloadLabel?.horizontalAlignmentMode = .center
        reloadLabel?.isHidden = true
        hudNode?.addChild(reloadLabel!)
    }
    
    // MARK: - Public Methods
    func addScore(_ points: Int = 1) {
        score += points
        scoreLabel?.text = String(format: GameConstants.Text.score, score)
    }
    
    func updateTime() {
        let playTime = gameStateManager.getPlayTime()
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        
        timeLabel?.text = String(format: GameConstants.Text.time, minutes, seconds)
    }
    
    func updatePlayerStats(health: Int, maxHealth: Int, ammo: Int, maxAmmo: Int, isReloading: Bool) {
        updateHealthBar(current: health, max: maxHealth)
        updateAmmoBar(current: ammo, max: maxAmmo, isReloading: isReloading)
    }
    
    private func updateHealthBar(current: Int, max: Int) {
        guard let healthBarFill = healthBarFill else { return }
        
        let healthRatio = CGFloat(current) / CGFloat(max)
        let barWidth: CGFloat = 200 - 4
        let newWidth = barWidth * healthRatio
        
        // 새로운 크기로 바 업데이트
        healthBarFill.removeFromParent()
        
        let newHealthFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 16), cornerRadius: 3)
        newHealthFill.fillColor = getHealthNeonColor(ratio: healthRatio)
        newHealthFill.strokeColor = SKColor.clear
        newHealthFill.position = CGPoint(x: -(barWidth - newWidth)/2, y: 0)
        
        healthBar?.addChild(newHealthFill)
        self.healthBarFill = newHealthFill
    }
    
    private func updateAmmoBar(current: Int, max: Int, isReloading: Bool) {
        guard let ammoBarFill = ammoBarFill else { return }
        
        let ammoRatio = CGFloat(current) / CGFloat(max)
        let barWidth: CGFloat = 200 - 4
        let newWidth = barWidth * ammoRatio
        
        // 새로운 크기로 바 업데이트
        ammoBarFill.removeFromParent()
        
        let newAmmoFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 16), cornerRadius: 3)
        newAmmoFill.fillColor = isReloading ? 
            SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8) : 
            SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8)
        newAmmoFill.strokeColor = SKColor.clear
        newAmmoFill.position = CGPoint(x: -(barWidth - newWidth)/2, y: 0)
        
        ammoBar?.addChild(newAmmoFill)
        self.ammoBarFill = newAmmoFill
        
        // 재장전 라벨 표시/숨김
        reloadLabel?.isHidden = !isReloading
    }
    
    private func getHealthNeonColor(ratio: CGFloat) -> SKColor {
        if ratio > 0.6 {
            return SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)  // 네온 그린
        } else if ratio > 0.3 {
            return SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8)  // 네온 옐로우
        } else {
            return SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)  // 네온 레드
        }
    }
    
    // MARK: - UI Visibility Control
    func hideHUD() {
        hudNode?.isHidden = true
    }
    
    func showHUD() {
        hudNode?.isHidden = false
    }
}
