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
    private weak var scene: SKScene?
    
    // MARK: - UI Elements
    private var scoreLabel: SKLabelNode?
    private var timeLabel: SKLabelNode?
    private var healthBar: SKShapeNode?
    private var healthBarFill: SKShapeNode?
    private var ammoBar: SKShapeNode?
    private var ammoBarFill: SKShapeNode?
    private var reloadLabel: SKLabelNode?
    private var exitButton: SKShapeNode?
    private var exitButtonLabel: SKLabelNode?
    
    // MARK: - Dependencies
    private let appRouter: AppRouter
    
    // MARK: - Game Data
    private(set) var score: Int = 0
    private let gameStateManager = GameStateManager.shared
    
    // MARK: - Initialization
    init(camera: SKCameraNode, appRouter: AppRouter) {
        self.camera = camera
        self.scene = camera.scene
        self.appRouter = appRouter
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
        setupExitButton()
        setupHealthBar()
        setupAmmoBar()
    }
    
    private func setupScoreLabel() {
        guard let scene = scene else { return }
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        
        scoreLabel = SKLabelNode(text: "SCORE: 0")
        scoreLabel?.fontName = "Arial-Bold"
        scoreLabel?.fontSize = 18
        scoreLabel?.fontColor = SKColor.white.withAlphaComponent(0.9)
        scoreLabel?.position = CGPoint(x: -sceneWidth/2 + 30, y: sceneHeight/2 - 50)
        scoreLabel?.horizontalAlignmentMode = .left
        
        // 배경 없이 심플하게
        hudNode?.addChild(scoreLabel!)
    }
    
    private func setupTimeLabel() {
        guard let scene = scene else { return }
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        
        timeLabel = SKLabelNode(text: "00:00")
        timeLabel?.fontName = "Arial-Bold"
        timeLabel?.fontSize = 20
        timeLabel?.fontColor = SKColor.white.withAlphaComponent(0.9)
        timeLabel?.position = CGPoint(x: -sceneWidth/2 + 30, y: sceneHeight/2 - 80)
        timeLabel?.horizontalAlignmentMode = .left
        
        // 배경 없이 심플하게
        hudNode?.addChild(timeLabel!)
    }
    
    private func setupExitButton() {
        guard let scene = scene else { return }
        let sceneHeight = scene.size.height
        
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 30
        let buttonX = scene.size.width/2 - 100
        let buttonY = sceneHeight/2 - 50  // 화면 상단에서 100pt 아래쪽에 위치
        
        // 나가기 버튼 배경 (검은 반투명 배경)
        exitButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 6)
        exitButton?.fillColor = SKColor.black.withAlphaComponent(0.3)
        exitButton?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        exitButton?.lineWidth = 1
        exitButton?.position = CGPoint(x: buttonX, y: buttonY)
        exitButton?.name = "exitButton"
        hudNode?.addChild(exitButton!)
        
        // 나가기 버튼 라벨
        exitButtonLabel = SKLabelNode(text: TextConstants.UI.exitButton)
        exitButtonLabel?.fontName = "Arial-Bold"
        exitButtonLabel?.fontSize = 14
        exitButtonLabel?.fontColor = SKColor.white.withAlphaComponent(0.9)
        exitButtonLabel?.position = CGPoint(x: 0, y: -5)
        exitButtonLabel?.horizontalAlignmentMode = .center
        exitButtonLabel?.name = "exitButtonLabel"
        exitButton?.addChild(exitButtonLabel!)
    }
    
    private func setupHealthBar() {
        guard let scene = scene else { return }
        let sceneHeight = scene.size.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 10
        let barY = -sceneHeight/2 + 40  // 화면 하단에서 50pt 위쪽에 위치
        
        // 체력 바 배경 (심플한 네온 스타일)
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        healthBar?.fillColor = SKColor.clear
        healthBar?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        healthBar?.lineWidth = 1
        healthBar?.position = CGPoint(x: 0, y: barY)
        hudNode?.addChild(healthBar!)
        
        // 체력 바 채우기 (네온 그린)
        healthBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        healthBarFill?.fillColor = UIConstants.Colors.HUD.healthBarColor
        healthBarFill?.strokeColor = SKColor.clear
        healthBarFill?.position = CGPoint(x: 0, y: 0)
        healthBar?.addChild(healthBarFill!)
        
        // 체력 라벨 (바 중앙 정렬)
        let healthLabel = SKLabelNode(text: "HP")
        healthLabel.fontName = "Arial-Bold"
        healthLabel.fontSize = 12
        healthLabel.fontColor = SKColor.white
        healthLabel.position = CGPoint(x: 0, y: -6)
        healthLabel.horizontalAlignmentMode = .center
        healthBar?.addChild(healthLabel)
    }
    
    private func setupAmmoBar() {    
        guard let scene = scene else { return }
        let sceneHeight = scene.size.height
        
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 10
        let barY = -sceneHeight/2 + 20  // 화면 하단에서 20pt 위쪽에 위치
        
        // 탄약 바 배경 (심플한 네온 스타일)
        ammoBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        ammoBar?.fillColor = SKColor.clear
        ammoBar?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        ammoBar?.lineWidth = 1
        ammoBar?.position = CGPoint(x: 0, y: barY)
        hudNode?.addChild(ammoBar!)
        
        // 탄약 바 채우기 (네온 시안)
        ammoBarFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        ammoBarFill?.fillColor = UIConstants.Colors.HUD.ammoBarColor
        ammoBarFill?.strokeColor = SKColor.clear
        ammoBarFill?.position = CGPoint(x: 0, y: 0)
        ammoBar?.addChild(ammoBarFill!)
        
        // 탄약 라벨 (바 중앙 정렬)
        let ammoLabel = SKLabelNode(text: "AMMO")
        ammoLabel.fontName = "Arial-Bold"
        ammoLabel.fontSize = 12
        ammoLabel.fontColor = SKColor.white
        ammoLabel.position = CGPoint(x: 0, y: -6)
        ammoLabel.horizontalAlignmentMode = .center
        ammoBar?.addChild(ammoLabel)
        
        // 재장전 라벨 (네온 스타일)
        reloadLabel = SKLabelNode(text: "RELOADING...")
        reloadLabel?.fontName = "Arial-Bold"
        reloadLabel?.fontSize = 16
        reloadLabel?.fontColor = UIConstants.Colors.HUD.reloadLabelColor
        reloadLabel?.position = CGPoint(x: barWidth/2 + 70, y: barY - 6)
        reloadLabel?.horizontalAlignmentMode = .center
        reloadLabel?.isHidden = true
        hudNode?.addChild(reloadLabel!)
    }
    
    // MARK: - Public Methods
    func addScore(_ points: Int = 1) {
        score += points
        scoreLabel?.text = String(format: TextConstants.HUD.scoreFormat, score)
    }
    
    func updateTime() {
        let playTime = gameStateManager.getPlayTime()
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        
        timeLabel?.text = String(format: TextConstants.HUD.timeFormat, minutes, seconds)
    }
    
    func updatePlayerStats(health: Int, maxHealth: Int, ammo: Int, maxAmmo: Int, isReloading: Bool) {
        updateHealthBar(current: health, max: maxHealth)
        updateAmmoBar(current: ammo, max: maxAmmo, isReloading: isReloading)
    }
    
    private func updateHealthBar(current: Int, max: Int) {
        guard let healthBarFill = healthBarFill else { return }
        
        let healthRatio = CGFloat(current) / CGFloat(max)
        let barWidth: CGFloat = 200 - 2
        let newWidth = barWidth * healthRatio
        
        // 새로운 크기로 바 업데이트
        healthBarFill.removeFromParent()
        
        let newHealthFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 10), cornerRadius: 3)
        newHealthFill.fillColor = getHealthNeonColor(ratio: healthRatio)
        newHealthFill.strokeColor = SKColor.clear
        newHealthFill.position = CGPoint(x: -(barWidth - newWidth)/2, y: 0)
        
        healthBar?.addChild(newHealthFill)
        self.healthBarFill = newHealthFill
    }
    
    private func updateAmmoBar(current: Int, max: Int, isReloading: Bool) {
        guard let ammoBarFill = ammoBarFill else { return }
        
        let ammoRatio = CGFloat(current) / CGFloat(max)
        let barWidth: CGFloat = 200 - 2
        let newWidth = barWidth * ammoRatio
        
        // 새로운 크기로 바 업데이트
        ammoBarFill.removeFromParent()
        
        let newAmmoFill = SKShapeNode(rectOf: CGSize(width: newWidth, height: 10), cornerRadius: 3)
        newAmmoFill.fillColor = isReloading ? 
            UIConstants.Colors.HUD.ammoReloadingColor : 
            UIConstants.Colors.HUD.ammoBarColor
        newAmmoFill.strokeColor = SKColor.clear
        newAmmoFill.position = CGPoint(x: -(barWidth - newWidth)/2, y: 0)
        
        ammoBar?.addChild(newAmmoFill)
        self.ammoBarFill = newAmmoFill
        
        // 재장전 라벨 표시/숨김
        reloadLabel?.isHidden = !isReloading
    }
    
    private func getHealthNeonColor(ratio: CGFloat) -> SKColor {
        if ratio > 0.6 {
            return UIConstants.Colors.HUD.healthHighColor
        } else if ratio > 0.3 {
            return UIConstants.Colors.HUD.healthMediumColor
        } else {
            return UIConstants.Colors.HUD.healthLowColor
        }
    }
    
    // MARK: - Touch Handling
    func handleTouch(at location: CGPoint) -> Bool {
        guard let hudNode = hudNode else { return false }
        
        // 노드 기반 터치 감지 - 훨씬 더 정확함
        let touchedNode = hudNode.atPoint(location)
        
        // 나가기 버튼이나 버튼 라벨이 터치되었는지 확인
        if touchedNode.name == "exitButton" || touchedNode.name == "exitButtonLabel" {
            // 버튼 사운드 및 햅틱 효과
            if AudioManager.shared.isSoundEffectsEnabled {
                let buttonSound = SKAction.playSoundFileNamed(ResourceConstants.Audio.SoundEffects.button, waitForCompletion: false)
                hudNode.run(buttonSound)
            }
            HapticManager.shared.playButtonHaptic()
            
            // 나가기 버튼 터치 효과
            exitButton?.run(SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            
            // 메인화면으로 이동
            DispatchQueue.main.async {
                self.appRouter.quitToMainMenu()
            }
            return true
        }
        
        return false
    }
    
    // MARK: - UI Visibility Control
    func hideHUD() {
        hudNode?.isHidden = true
    }
    
    func showHUD() {
        hudNode?.isHidden = false
    }
}
