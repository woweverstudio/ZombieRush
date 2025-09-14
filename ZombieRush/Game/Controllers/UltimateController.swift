//
//  UltimateController.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class UltimateController: NSObject {

    // MARK: - Properties
    private weak var scene: SKScene?
    private weak var cameraNode: SKCameraNode?
    private weak var player: Player?
    private var ultimateButton: SKNode?
    private var progressRing: SKShapeNode?
    private var buttonSprite: SKSpriteNode?

    // MARK: - Managers
    private let hapticManager = HapticManager.shared
    private weak var toastMessageManager: ToastMessageManager?

    // MARK: - Ultimate Skill
    private var ultimateSkill: UltimateSkill

    // MARK: - Ultimate Gauge
    private var ultimateGauge: Int = 0 // 0 ~ 100 (좀비 공격 시 1씩 증가)

    // MARK: - UI Constants
    private let buttonSize: CGFloat = UIConstants.Controls.joystickRadius
    private let ringRadius: CGFloat = UIConstants.Controls.joystickRadius - 10
    private let ringLineWidth: CGFloat = 3

    // MARK: - Screen Bounds (GameController와 동일한 방식)
    private let screenBounds: CGSize = UIScreen.main.bounds.size

    // MARK: - Calculated Properties
    private var buttonPosition: CGPoint {
        // GameController처럼 screenBounds를 사용한 우하단 위치 계산
        CGPoint(
            x: screenBounds.width / 2 - UIConstants.Layout.controlMargin,
            y: -screenBounds.height / 2 + UIConstants.Layout.controlMargin
        )
    }

    // MARK: - Initialization
    init(scene: SKScene, cameraNode: SKCameraNode, player: Player, skill: UltimateSkill, toastMessageManager: ToastMessageManager) {
        self.scene = scene
        self.cameraNode = cameraNode
        self.player = player
        self.ultimateSkill = skill
        self.toastMessageManager = toastMessageManager

        super.init()

        setupUltimateButton()
        setupProgressRing()
        setupGameProgress()
    }

    // MARK: - Setup Methods
    private func setupUltimateButton() {
        guard let cameraNode = cameraNode else {
            return
        }

        // 버튼 컨테이너 노드 생성
        let buttonContainer = SKNode()
        buttonContainer.position = buttonPosition
        buttonContainer.name = TextConstants.NodeNames.ultimateButton  // 중앙 집중화된 노드 이름 사용
        buttonContainer.zPosition = 200  // HUD 요소들보다 높은 zPosition

        // camera에 버튼 추가
        cameraNode.addChild(buttonContainer)

        // 버튼 스프라이트 (비율 유지)
        buttonSprite = SKSpriteNode(imageNamed: getButtonImageName())
        if let buttonSprite = buttonSprite {
            // 이미지 비율 유지
            maintainButtonAspectRatio(for: buttonSprite)
            buttonSprite.zPosition = 100
        }

        if let buttonSprite = buttonSprite {
            buttonContainer.addChild(buttonSprite)
        }

        ultimateButton = buttonContainer
    }

    private func setupProgressRing() {
        guard let ultimateButton = ultimateButton else { return }

        // 배경 링 (전체 회색 링)
        let backgroundRing = SKShapeNode(circleOfRadius: ringRadius)
        backgroundRing.strokeColor = UIColor.gray.withAlphaComponent(0.3) // 회색 배경
        backgroundRing.fillColor = .clear
        backgroundRing.lineWidth = ringLineWidth
        backgroundRing.lineCap = .round  // 모서리 둥글게
        backgroundRing.zPosition = 98

        // 채움 게이지 링 (붉은 네온)
        progressRing = SKShapeNode()
        progressRing?.strokeColor = getRingColor()
        progressRing?.fillColor = .clear
        progressRing?.lineWidth = ringLineWidth
        progressRing?.lineCap = .round  // 모서리 둥글게
        progressRing?.zPosition = 99

        if let progressRing = progressRing {
            ultimateButton.addChild(backgroundRing)
            ultimateButton.addChild(progressRing)
        }

        updateProgressRing()
    }

    private func setupGameProgress() {
        // 게임 시작 시 초기화
        ultimateGauge = 0
    }


    // MARK: - Zombie Attack
    /// 좀비를 공격할 때마다 호출하여 게이지 증가
    func onZombieAttacked() {
        guard ultimateGauge < 100 else { return }

        let previousGauge = ultimateGauge
        ultimateGauge += 1

        // 게이지가 100이 되는 순간을 감지하여 피드백 제공
        if previousGauge < 100 && ultimateGauge >= 100 {
            triggerUltimateReadyFeedback()
        }

        updateUltimateButton()
        updateProgressRing()
    }

    // MARK: - Ultimate Ready Feedback
    private func triggerUltimateReadyFeedback() {
        // 강한 햅틱 피드백
        hapticManager.playUltimateReadyHaptic()

        // 토스트 메시지 표시
        let message = TextConstants.Ultimate.ultimateReady
        toastMessageManager?.showToastMessage(message, duration: 3.0)
    }

    // MARK: - UI Updates
    private func updateUltimateButton() {
        let imageName = getButtonImageName()
        if let buttonSprite = buttonSprite {
            buttonSprite.texture = SKTexture(imageNamed: imageName)
            // 이미지 변경 시 비율 유지
            maintainButtonAspectRatio(for: buttonSprite)
        }
    }

    private func updateProgressRing() {
        guard let progressRing = progressRing else { return }

        let progress = CGFloat(ultimateGauge) / 100.0

        // 시계 방향으로 게이지가 채워지는 호 생성
        let path = createGaugePath(progress: progress)
        progressRing.path = path

        // 게이지에 따른 색상과 효과 설정
        if progress >= 1.0 {
            // 완전 충전 상태
            progressRing.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else if progress > 0 {
            // 충전 중 상태
            let intensity = 0.6 + (progress * 0.4) // 0.6 ~ 1.0
            progressRing.strokeColor = UIColor(red: intensity, green: 0.0, blue: 0.0, alpha: intensity)
        } else {
            // 빈 상태 - 투명하게 처리 (보이지 않음)
            progressRing.strokeColor = UIColor.clear
        }
    }

    private func createGaugePath(progress: CGFloat) -> CGPath {
        // 시계 방향 게이지 생성 (12시 방향에서 시작)
        let startAngle = -CGFloat.pi / 2  // 12시 방향 (-90도)
        let endAngle = startAngle + (progress * 2 * CGFloat.pi)  // 게이지에 따라 호 길이 결정

        let center = CGPoint.zero
        let radius = ringRadius

        // UIBezierPath를 사용하여 호 생성
        let path = UIBezierPath()
        path.addArc(withCenter: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: true)

        return path.cgPath
    }

    // MARK: - Helper Methods
    private func getButtonImageName() -> String {
        let baseImageName = ultimateSkill.imageName

        // 게이지가 100이 아니면 deactive 이미지 사용
        if ultimateGauge >= 100 {
            return "\(baseImageName)_active"
        } else {
            return "\(baseImageName)_deactive"
        }
    }

    private func maintainButtonAspectRatio(for sprite: SKSpriteNode) {
        guard let texture = sprite.texture else {
            // 텍스처가 없으면 기본 크기 사용
            sprite.size = CGSize(width: buttonSize, height: buttonSize)
            return
        }

        let originalSize = texture.size()
        let targetSize = CGSize(width: buttonSize, height: buttonSize)

        // 원본 비율을 유지하면서 targetSize에 맞춤 (aspect fit)
        let scaleX = targetSize.width / originalSize.width
        let scaleY = targetSize.height / originalSize.height
        let scale = min(scaleX, scaleY)

        sprite.size = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
    }

    private func imageExists(_ imageName: String) -> Bool {
        // SKTexture로 이미지가 로드되는지 확인
        return SKTexture(imageNamed: imageName).size() != CGSize.zero
    }

    private func getRingColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8) // 네온 빨강
    }


    // MARK: - Public Methods
    func handleTouch(at location: CGPoint) -> Bool {
        guard let ultimateButton = ultimateButton,
              ultimateGauge >= 100 else { return false }

        // SKNode의 containsPoint 메소드를 사용한 간단한 터치 확인
        if ultimateButton.contains(location) {
            hapticManager.playHeavyHaptic()
            activateUltimate()
            return true
        }

        return false
    }

    func activateUltimate() {
        // 버튼 피드백 애니메이션
        animateButtonActivation()

        // 플레이어 위치 가져오기
        let playerPosition = player?.position ?? CGPoint.zero

        // 궁극기 발동
        if let scene = scene {
            ultimateSkill.execute(at: playerPosition, in: scene)
        }

        // 궁극기 사용 시 게이지 0으로 리셋
        ultimateGauge = 0
        updateUltimateButton()
        updateProgressRing()
    }

    private func animateButtonActivation() {
        guard let buttonSprite = buttonSprite else { return }

        // 버튼 활성화 애니메이션
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])

        buttonSprite.run(sequence)

        // 링 플래시 효과
        guard let progressRing = progressRing else { return }

        let originalColor = progressRing.strokeColor
        let flashColor = UIColor.white

        let flashAction = SKAction.sequence([
            SKAction.run { progressRing.strokeColor = flashColor },
            SKAction.wait(forDuration: 0.2),
            SKAction.run { progressRing.strokeColor = originalColor }
        ])

        progressRing.run(flashAction)
    }
    
    func hideUI() {
        ultimateButton?.isHidden = true
    }

    // MARK: - Cleanup
    func removeFromScene() {
        ultimateButton?.removeFromParent()
    }
}
