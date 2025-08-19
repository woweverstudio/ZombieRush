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
        
        // 게임오버 배경 이미지
        createGameOverBackground()
        
        // 네온 결과 정보
        createNeonResultLabels(playTime: playTime, score: score, wave: wave)
        
        // 네온 버튼들
        createNeonButtons()
    }
    
    private func createGameOverBackground() {
        guard let gameOverNode = gameOverNode else { return }
        
        // 게임오버 배경 이미지
        let backgroundImage = SKSpriteNode(imageNamed: "gameover")
        backgroundImage.position = CGPoint.zero
        backgroundImage.zPosition = -2
        
        // 화면에 맞게 스케일 조정
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scaleX = screenWidth / backgroundImage.size.width
        let scaleY = screenHeight / backgroundImage.size.height
        let scale = max(scaleX, scaleY) // 화면을 완전히 덮도록 큰 값 사용
        
        backgroundImage.setScale(scale)
        gameOverNode.addChild(backgroundImage)
        
        // 반투명 검은색 오버레이 (가독성 향상)
        // let overlay = SKShapeNode(rect: CGRect(
        //     x: -screenWidth/2, y: -screenHeight/2,
        //     width: screenWidth, height: screenHeight
        // ))
        // overlay.fillColor = SKColor.black.withAlphaComponent(0.2) // 20% 불투명
        // overlay.strokeColor = SKColor.clear
        // overlay.zPosition = -1
        // gameOverNode.addChild(overlay)
    }
    
    private func createNeonResultLabels(playTime: TimeInterval, score: Int, wave: Int) {
        guard let gameOverNode = gameOverNode else { return }
        
        // 화면 너비 기준으로 계산
        let screenWidth = UIScreen.main.bounds.width
        let topY: CGFloat = 100  // 상단 위치
        let margin: CGFloat = 150  // 좌우 여백
        
        // 3등분 위치 계산
        let leftX = -screenWidth/2 + margin
        let centerX: CGFloat = 0
        let rightX = screenWidth/2 - margin
        
        // 플레이 시간 (왼쪽)
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        let timeText = String(format: "TIME: %02d:%02d", minutes, seconds)
        let timeLabel = createWhiteLabel(text: timeText, fontSize: 20)
        timeLabel.horizontalAlignmentMode = .left  // 왼쪽 정렬
        timeLabel.position = CGPoint(x: leftX, y: topY)
        gameOverNode.addChild(timeLabel)
        
        // 좀비 처치수 (중앙)
        let scoreText = "KILLS: \(score)"
        let scoreLabel = createWhiteLabel(text: scoreText, fontSize: 20)
        scoreLabel.horizontalAlignmentMode = .center  // 중앙 정렬
        scoreLabel.position = CGPoint(x: centerX, y: topY)
        gameOverNode.addChild(scoreLabel)
        
        // 웨이브 (오른쪽)
        let waveText = "WAVE: \(wave)"
        let waveLabel = createWhiteLabel(text: waveText, fontSize: 20)
        waveLabel.horizontalAlignmentMode = .right  // 오른쪽 정렬
        waveLabel.position = CGPoint(x: rightX, y: topY)
        gameOverNode.addChild(waveLabel)
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
        guard let gameOverNode = gameOverNode else { return }
        
        // 그만하기 버튼 (레드 배경) - 왼쪽으로 이동
        let quitButton = createSolidButton(
            text: "QUIT",
            position: CGPoint(x: -120, y: -120),
            backgroundColor: SKColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0),
            name: "QuitButton"
        )
        gameOverNode.addChild(quitButton)
        
        // 다시하기 버튼 (그린 배경) - 오른쪽으로 이동
        let restartButton = createSolidButton(
            text: "RESTART",
            position: CGPoint(x: 120, y: -120),
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
                // 버튼 사운드 재생 (직접 SKAction 사용)
                if AudioManager.shared.isSoundEffectsEnabled {
                    let buttonSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.button, waitForCompletion: false)
                    gameOverNode.run(buttonSound)
                }
                // 버튼 햅틱 피드백
                HapticManager.shared.playButtonHaptic()
                onRestart?()
                return true
            case "QuitButton":
                // 버튼 사운드 재생 (직접 SKAction 사용)
                if AudioManager.shared.isSoundEffectsEnabled {
                    let buttonSound = SKAction.playSoundFileNamed(GameConstants.Audio.SoundEffects.button, waitForCompletion: false)
                    gameOverNode.run(buttonSound)
                }
                // 버튼 햅틱 피드백
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
