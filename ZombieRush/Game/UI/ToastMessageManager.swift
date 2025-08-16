import SpriteKit

class ToastMessageManager {
    
    // MARK: - Properties
    private weak var camera: SKCameraNode?
    private weak var player: Player?
    
    // 활성 토스트 메시지들을 관리하는 배열
    private var activeToasts: [SKNode] = []
    private let maxToasts = 3  // 최대 3개까지 동시 표시
    
    // MARK: - Initialization
    init(camera: SKCameraNode, player: Player) {
        self.camera = camera
        self.player = player
    }
    
    // MARK: - Public Methods
    func showToastMessage(_ text: String, duration: TimeInterval = GameConstants.ToastMessage.defaultDuration) {
        guard let player = player else { return }
        
        // 기존 토스트들을 위로 밀어올리기
        pushExistingToastsUp()
        
        // 최대 개수 초과 시 가장 오래된 토스트 제거
        if activeToasts.count >= maxToasts {
            removeOldestToast()
        }
        
        // 새 토스트 메시지 노드 생성
        let toastNode = createToastNode(text: text)
        
        // 플레이어 머리 위 위치 설정 (가장 아래 위치)
        toastNode.position = CGPoint(x: 0, y: GameConstants.ToastMessage.offsetY)
        
        // 플레이어에 직접 추가
        player.addChild(toastNode)
        activeToasts.append(toastNode)
        
        // 애니메이션 시퀀스
        let appearAnimation = createAppearAnimation()
        let waitAction = SKAction.wait(forDuration: duration)
        let disappearAnimation = createDisappearAnimation()
        let removeAction = SKAction.run { [weak self] in
            self?.removeToast(toastNode)
        }
        
        let sequence = SKAction.sequence([
            appearAnimation,
            waitAction,
            disappearAnimation,
            removeAction
        ])
        
        toastNode.run(sequence, withKey: "toastLifecycle")
    }
    
    // MARK: - Private Methods
    private func createToastNode(text: String) -> SKNode {
        let containerNode = SKNode()
        containerNode.name = GameConstants.NodeNames.toastMessage
        containerNode.zPosition = GameConstants.ToastMessage.zPosition
        
        // 텍스트 라벨 생성
        let label = createLabel(text: text, color: SKColor.white)
        
        // 텍스트에 검은 테두리 효과 (가독성 향상)
        let shadowLabel = createLabel(text: text, color: SKColor.black)
        shadowLabel.position = GameConstants.ToastMessage.shadowOffset
        shadowLabel.zPosition = -1
        
        containerNode.addChild(shadowLabel)
        containerNode.addChild(label)
        
        // 초기 상태 설정 (애니메이션을 위해)
        containerNode.alpha = 0
        containerNode.setScale(GameConstants.ToastMessage.initialScale)
        
        return containerNode
    }
    
    private func createLabel(text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = GameConstants.ToastMessage.fontSize
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
    
    private func createAppearAnimation() -> SKAction {
        return AnimationUtils.createAppearEffect(
            scale: GameConstants.ToastMessage.initialScale,
            targetScale: 1.0,
            duration: GameConstants.ToastMessage.appearDuration
        )
    }
    
    private func createDisappearAnimation() -> SKAction {
        return AnimationUtils.createDisappearEffect(
            scale: GameConstants.ToastMessage.finalScale,
            duration: GameConstants.ToastMessage.disappearDuration
        )
    }
    
    // MARK: - Stack Management
    private func pushExistingToastsUp() {
        for (index, toast) in activeToasts.enumerated() {
            let targetY = GameConstants.ToastMessage.offsetY + CGFloat(index + 1) * GameConstants.ToastMessage.stackSpacing
            
            // 위로 이동 애니메이션
            let moveUp = SKAction.moveTo(y: targetY, duration: GameConstants.ToastMessage.stackAnimationDuration)
            
            // 크기 축소 애니메이션 (위로 갈수록 작아짐)
            let newScale = 1.0 - CGFloat(index + 1) * GameConstants.ToastMessage.stackScaleReduction
            let scaleDown = SKAction.scale(to: max(newScale, GameConstants.ToastMessage.minStackScale), duration: GameConstants.ToastMessage.stackAnimationDuration)
            
            // 투명도 감소 (위로 갈수록 투명해짐)
            let newAlpha = 1.0 - CGFloat(index + 1) * GameConstants.ToastMessage.stackAlphaReduction
            let fadeOut = SKAction.fadeAlpha(to: max(newAlpha, GameConstants.ToastMessage.minStackAlpha), duration: GameConstants.ToastMessage.stackAnimationDuration)
            
            let pushAnimation = SKAction.group([moveUp, scaleDown, fadeOut])
            toast.run(pushAnimation, withKey: "pushUp")
        }
    }
    
    private func removeOldestToast() {
        guard let oldestToast = activeToasts.first else { return }
        
        // 즉시 제거 애니메이션
        let quickFade = SKAction.fadeOut(withDuration: GameConstants.ToastMessage.quickRemovalDuration)
        let quickScale = SKAction.scale(to: GameConstants.ToastMessage.quickRemovalScale, duration: GameConstants.ToastMessage.quickRemovalDuration)
        let quickRemove = SKAction.group([quickFade, quickScale])
        
        oldestToast.run(quickRemove) { [weak self] in
            oldestToast.removeFromParent()
            self?.activeToasts.removeFirst()
        }
    }
    
    private func removeToast(_ toast: SKNode) {
        toast.removeFromParent()
        
        // 배열에서 제거
        if let index = activeToasts.firstIndex(of: toast) {
            activeToasts.remove(at: index)
            
            // 남은 토스트들의 위치 재조정
            repositionRemainingToasts()
        }
    }
    
    private func repositionRemainingToasts() {
        for (index, toast) in activeToasts.enumerated() {
            let targetY = GameConstants.ToastMessage.offsetY + CGFloat(index) * GameConstants.ToastMessage.stackSpacing
            let targetScale = 1.0 - CGFloat(index) * GameConstants.ToastMessage.stackScaleReduction
            let targetAlpha = 1.0 - CGFloat(index) * GameConstants.ToastMessage.stackAlphaReduction
            
            let moveAnimation = SKAction.moveTo(y: targetY, duration: GameConstants.ToastMessage.repositionDuration)
            let scaleAnimation = SKAction.scale(to: max(targetScale, GameConstants.ToastMessage.minStackScale), duration: GameConstants.ToastMessage.repositionDuration)
            let alphaAnimation = SKAction.fadeAlpha(to: max(targetAlpha, GameConstants.ToastMessage.minStackAlpha), duration: GameConstants.ToastMessage.repositionDuration)
            
            let repositionAnimation = SKAction.group([moveAnimation, scaleAnimation, alphaAnimation])
            toast.run(repositionAnimation, withKey: "reposition")
        }
    }
}
