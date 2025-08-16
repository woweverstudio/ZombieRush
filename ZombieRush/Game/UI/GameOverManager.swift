import SpriteKit
import UIKit

class GameOverManager {
    
    // MARK: - Properties
    private weak var camera: SKCameraNode?
    private var gameOverNode: SKNode?
    private var isGameOver = false
    
    // MARK: - Callbacks
    var onRestart: (() -> Void)?
    var onQuit: (() -> Void)?
    
    // MARK: - Initialization
    init(camera: SKCameraNode) {
        self.camera = camera
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
        
        // 반투명 배경
        let backgroundSize = GameConstants.UI.gameOverBackgroundSize
        let background = SKShapeNode(rect: CGRect(x: -backgroundSize.width/2, y: -backgroundSize.height/2, width: backgroundSize.width, height: backgroundSize.height))
        background.fillColor = SKColor.black
        background.alpha = 0.8
        background.strokeColor = SKColor.clear
        gameOverNode!.addChild(background)
        
        // 게임오버 타이틀
        let titleLabel = SKLabelNode(text: GameConstants.Text.gameOver)
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontSize = GameConstants.UI.gameOverTitleFontSize
        titleLabel.fontColor = SKColor.red
        titleLabel.position = CGPoint(x: 0, y: 150)
        gameOverNode!.addChild(titleLabel)
        
        // 결과 정보
        createResultLabels(playTime: playTime, score: score, wave: wave)
        
        // 버튼들
        createButtons()
    }
    
    private func createResultLabels(playTime: TimeInterval, score: Int, wave: Int) {
        guard let gameOverNode = gameOverNode else { return }
        
        // 플레이 시간
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        let timeText = String(format: "플레이 시간: %02d:%02d", minutes, seconds)
        let timeLabel = SKLabelNode(text: timeText)
        timeLabel.fontName = "HelveticaNeue"
        timeLabel.fontSize = 24
        timeLabel.fontColor = SKColor.white
        timeLabel.position = CGPoint(x: 0, y: 50)
        gameOverNode.addChild(timeLabel)
        
        // 좀비 처치수
        let scoreLabel = SKLabelNode(text: "좀비 처치: \(score)마리")
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 0, y: 10)
        gameOverNode.addChild(scoreLabel)
        
        // 웨이브 (임시로 0)
        let waveLabel = SKLabelNode(text: "웨이브: \(wave)")
        waveLabel.fontName = "HelveticaNeue"
        waveLabel.fontSize = 24
        waveLabel.fontColor = SKColor.white
        waveLabel.position = CGPoint(x: 0, y: -30)
        gameOverNode.addChild(waveLabel)
    }
    
    private func createButtons() {
        guard let gameOverNode = gameOverNode else { return }
        
        // 다시하기 버튼
        let restartButton = createButton(
            text: "다시하기",
            position: CGPoint(x: -100, y: -120),
            color: SKColor.green,
            name: "RestartButton"
        )
        gameOverNode.addChild(restartButton)
        
        // 그만하기 버튼
        let quitButton = createButton(
            text: "그만하기",
            position: CGPoint(x: 100, y: -120),
            color: SKColor.red,
            name: "QuitButton"
        )
        gameOverNode.addChild(quitButton)
    }
    
    private func createButton(text: String, position: CGPoint, color: SKColor, name: String) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = name
        buttonNode.position = position
        
        // 버튼 배경
        let buttonBG = SKShapeNode(rect: CGRect(x: -60, y: -20, width: 120, height: 40))
        buttonBG.fillColor = color.withAlphaComponent(0.8)
        buttonBG.strokeColor = SKColor.white
        buttonBG.lineWidth = 2
        buttonNode.addChild(buttonBG)
        
        // 버튼 텍스트
        let buttonLabel = SKLabelNode(text: text)
        buttonLabel.fontName = "HelveticaNeue-Bold"
        buttonLabel.fontSize = 18
        buttonLabel.fontColor = SKColor.white
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
                onRestart?()
                return true
            case "QuitButton":
                onQuit?()
                return true
            default:
                break
            }
        }
        
        return false
    }
}
