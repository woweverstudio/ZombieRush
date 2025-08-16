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
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel?.fontName = "Arial-Bold"
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = .white
        scoreLabel?.position = CGPoint(x: -screenWidth/2 + 120, y: screenHeight/2 - 60)
        scoreLabel?.horizontalAlignmentMode = .left
        
        // 배경 추가
        let background = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 8)
        background.fillColor = SKColor.black.withAlphaComponent(0.6)
        background.strokeColor = SKColor.white.withAlphaComponent(0.3)
        background.lineWidth = 1
        background.position = CGPoint(x: 75, y: 0)
        background.zPosition = -1
        
        scoreLabel?.addChild(background)
        hudNode?.addChild(scoreLabel!)
    }
    
    private func setupTimeLabel() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        timeLabel = SKLabelNode(text: "Time: 00:00")
        timeLabel?.fontName = "Arial-Bold"
        timeLabel?.fontSize = 24
        timeLabel?.fontColor = .white
        timeLabel?.position = CGPoint(x: screenWidth/2 - 120, y: screenHeight/2 - 60)
        timeLabel?.horizontalAlignmentMode = .right
        
        // 배경 추가
        let background = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 8)
        background.fillColor = SKColor.black.withAlphaComponent(0.6)
        background.strokeColor = SKColor.white.withAlphaComponent(0.3)
        background.lineWidth = 1
        background.position = CGPoint(x: -75, y: 0)
        background.zPosition = -1
        
        timeLabel?.addChild(background)
        hudNode?.addChild(timeLabel!)
    }
    
    private func setupHealthBar() {
        let screenHeight = UIScreen.main.bounds.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 20
        let barY = -screenHeight/2 + 60
        
        // 체력 바 배경
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        healthBar?.fillColor = SKColor.black.withAlphaComponent(0.6)
        healthBar?.strokeColor = SKColor.white.withAlphaComponent(0.8)
        healthBar?.lineWidth = 2
        healthBar?.position = CGPoint(x: -barWidth/2, y: barY)
        hudNode?.addChild(healthBar!)
        
        // 체력 바 채우기
        healthBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 8)
        healthBarFill?.fillColor = SKColor.green
        healthBarFill?.strokeColor = SKColor.clear
        healthBarFill?.position = CGPoint(x: 0, y: 0)
        healthBar?.addChild(healthBarFill!)
        
        // 체력 라벨
        let healthLabel = SKLabelNode(text: "HP")
        healthLabel.fontName = "Arial-Bold"
        healthLabel.fontSize = 16
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: -barWidth/2 - 30, y: barY - 8)
        healthLabel.horizontalAlignmentMode = .center
        hudNode?.addChild(healthLabel)
    }
    
    private func setupAmmoBar() {    
        let screenHeight = UIScreen.main.bounds.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 20
        let barY = -screenHeight/2 + 30
        
        // 탄약 바 배경
        ammoBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        ammoBar?.fillColor = SKColor.black.withAlphaComponent(0.6)
        ammoBar?.strokeColor = SKColor.white.withAlphaComponent(0.8)
        ammoBar?.lineWidth = 2
        ammoBar?.position = CGPoint(x: -barWidth/2, y: barY)
        hudNode?.addChild(ammoBar!)
        
        // 탄약 바 채우기
        ammoBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 8)
        ammoBarFill?.fillColor = SKColor.blue
        ammoBarFill?.strokeColor = SKColor.clear
        ammoBarFill?.position = CGPoint(x: 0, y: 0)
        ammoBar?.addChild(ammoBarFill!)
        
        // 탄약 라벨
        let ammoLabel = SKLabelNode(text: "AMMO")
        ammoLabel.fontName = "Arial-Bold"
        ammoLabel.fontSize = 16
        ammoLabel.fontColor = .white
        ammoLabel.position = CGPoint(x: -barWidth/2 - 50, y: barY - 8)
        ammoLabel.horizontalAlignmentMode = .center
        hudNode?.addChild(ammoLabel)
        
        // 재장전 라벨
        reloadLabel = SKLabelNode(text: "RELOADING...")
        reloadLabel?.fontName = "Arial-Bold"
        reloadLabel?.fontSize = 18
        reloadLabel?.fontColor = .yellow
        reloadLabel?.position = CGPoint(x: barWidth/2 + 80, y: barY - 8)
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
        
        let newHealthFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 16), cornerRadius: 8)
        newHealthFill.fillColor = getHealthColor(ratio: healthRatio)
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
        
        let newAmmoFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 16), cornerRadius: 8)
        newAmmoFill.fillColor = isReloading ? SKColor.orange : SKColor.blue
        newAmmoFill.strokeColor = SKColor.clear
        newAmmoFill.position = CGPoint(x: -(barWidth - newWidth)/2, y: 0)
        
        ammoBar?.addChild(newAmmoFill)
        self.ammoBarFill = newAmmoFill
        
        // 재장전 라벨 표시/숨김
        reloadLabel?.isHidden = !isReloading
    }
    
    private func getHealthColor(ratio: CGFloat) -> SKColor {
        if ratio > 0.6 {
            return .green
        } else if ratio > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
}
