import SpriteKit
import UIKit

class GameOverManager {
    
    // MARK: - Properties
    private weak var camera: SKCameraNode?
    private weak var scene: SKScene?
    private var gameOverNode: SKNode?
    private var isGameOver = false
    
    // MARK: - Callbacks
    var onRestart: (() -> Void)?
    var onQuit: (() -> Void)?
    
    // MARK: - Initialization
    init(camera: SKCameraNode) {
        self.camera = camera
        self.scene = camera.scene
    }
    
    // MARK: - Public Methods
    func showGameOver(playTime: TimeInterval, score: Int, wave: Int = 0) {
        guard !isGameOver else { return }
        isGameOver = true
        
        createGameOverUI(playTime: playTime, score: score, wave: wave)
    }
    
    func hideGameOver() {
        gameOverNode?.removeFromParent()
        gameOverNode = nil
        isGameOver = false
    }
    
    // MARK: - Private Methods
    private func createGameOverUI(playTime: TimeInterval, score: Int, wave: Int) {
        guard let camera = camera else { return }
        
        // 메인 컨테이너
        gameOverNode = SKNode()
        gameOverNode!.name = GameConstants.NodeNames.gameOverUI
        camera.addChild(gameOverNode!)
        
        // 게임오버 배경 이미지
        createGameOverBackground()
        
        // 네온 결과 정보
        createNeonResultLabels(playTime: playTime, score: score, wave: wave)
        
        // 네온 버튼들
        createNeonButtons()
    }
    
    private func createGameOverBackground() {
        guard let gameOverNode = gameOverNode, let scene = scene else { return }
        
        // 게임오버 배경 이미지
        let backgroundImage = SKSpriteNode(imageNamed: "gameover")
        backgroundImage.position = CGPoint.zero
        backgroundImage.zPosition = -2
        
        // 씬 크기에 맞게 스케일 조정
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        let scaleX = sceneWidth / backgroundImage.size.width
        let scaleY = sceneHeight / backgroundImage.size.height
        let scale = max(scaleX, scaleY) // 화면을 완전히 덮도록 큰 값 사용
        
        backgroundImage.setScale(scale)
        gameOverNode.addChild(backgroundImage)
        
        // 개별 배경은 각 라벨에서 생성
    }
    
    private func createNeonResultLabels(playTime: TimeInterval, score: Int, wave: Int) {
        guard let gameOverNode = gameOverNode, let scene = scene else { return }
        
        // 세로 스택 배치
        let centerX: CGFloat = -scene.size.width/2 + 30
        let spacing: CGFloat = 50  // 라벨 간 간격 (배경 포함)
        let startY: CGFloat = scene.size.height/2 - 50
        
        // 플레이 시간 (상단)
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        let timeText = String(format: "TIME: %02d:%02d", minutes, seconds)
        let timePanel = createInfoPanel(text: timeText, position: CGPoint(x: centerX, y: startY))
        gameOverNode.addChild(timePanel)
        
        // 좀비 처치수 (중앙)
        let scoreText = "KILLS: \(score)"
        let scorePanel = createInfoPanel(text: scoreText, position: CGPoint(x: centerX, y: startY - spacing))
        gameOverNode.addChild(scorePanel)
        
        // 웨이브 (하단)
        let waveText = "WAVE: \(wave)"
        let wavePanel = createInfoPanel(text: waveText, position: CGPoint(x: centerX, y: startY - spacing * 2))
        gameOverNode.addChild(wavePanel)
    }
    
    private func createInfoPanel(text: String, position: CGPoint) -> SKNode {
        let panelNode = SKNode()
        panelNode.position = position
        
        // 개별 배경 패널
        let panelWidth: CGFloat = 200
        let panelHeight: CGFloat = 35
        let backgroundPanel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 8)
        backgroundPanel.fillColor = SKColor.black.withAlphaComponent(0.9)
        backgroundPanel.strokeColor = SKColor.white.withAlphaComponent(0.3)
        backgroundPanel.lineWidth = 1.5
        backgroundPanel.position = CGPoint(x: 0, y: 0)
        panelNode.addChild(backgroundPanel)
        
        // 텍스트 라벨
        let label = SKLabelNode(text: text)
        label.fontName = "Arial-Bold"
        label.fontSize = 16
        label.fontColor = SKColor.white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        panelNode.addChild(label)
        
        return panelNode
    }
    
    private func createWhiteLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Arial-Bold"
        label.fontSize = fontSize
        label.fontColor = SKColor.white
        // horizontalAlignmentMode는 각 라벨에서 개별 설정
        return label
    }
    
    private func createNeonButtons() {
        guard let gameOverNode = gameOverNode, let scene = scene else { return }
        
        let sceneHeight = scene.size.height
        let buttonY = -sceneHeight/2 + 80  // 화면 하단에서 80pt 위
        
        // 그만하기 버튼 (레드 배경) - 왼쪽
        let quitButton = createSolidButton(
            text: "QUIT",
            position: CGPoint(x: -120, y: buttonY),
            backgroundColor: SKColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0),
            name: "QuitButton"
        )
        gameOverNode.addChild(quitButton)
        
        // 다시하기 버튼 (그린 배경) - 오른쪽
        let restartButton = createSolidButton(
            text: "RESTART",
            position: CGPoint(x: 120, y: buttonY),
            backgroundColor: SKColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1.0),
            name: "RestartButton"
        )
        gameOverNode.addChild(restartButton)
    }
    
    private func createSolidButton(text: String, position: CGPoint, backgroundColor: SKColor, name: String) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = name
        buttonNode.position = position
        
        // 꽉 찬 배경 버튼
        let buttonBG = SKShapeNode(rect: CGRect(x: -70, y: -25, width: 140, height: 50), cornerRadius: 8)
        buttonBG.fillColor = backgroundColor
        buttonBG.strokeColor = backgroundColor
        buttonBG.lineWidth = 2
        buttonNode.addChild(buttonBG)
        
        // 두꺼운 검은색 텍스트
        let buttonLabel = SKLabelNode(text: text)
        buttonLabel.fontName = "Arial-Black"  // 더 두꺼운 폰트
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = SKColor.black
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.verticalAlignmentMode = .center
        buttonNode.addChild(buttonLabel)
        
        return buttonNode
    }
    
    // MARK: - Touch Handling
    func handleTouch(at location: CGPoint) -> Bool {
        guard isGameOver, let gameOverNode = gameOverNode else { return false }
        
        let touchedNode = gameOverNode.atPoint(location)
        
        if let nodeName = touchedNode.parent?.name {
            switch nodeName {
            case "RestartButton":
                if AudioManager.shared.isSoundEffectsEnabled {
                    let buttonSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.button, waitForCompletion: false)
                    gameOverNode.run(buttonSound)
                }
                HapticManager.shared.playButtonHaptic()
                onRestart?()
                return true
            case "QuitButton":
                if AudioManager.shared.isSoundEffectsEnabled {
                    let buttonSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.button, waitForCompletion: false)
                    gameOverNode.run(buttonSound)
                }
                HapticManager.shared.playButtonHaptic()
                onQuit?()
                return true
            default:
                break
            }
        }
        
        return false
    }
}
