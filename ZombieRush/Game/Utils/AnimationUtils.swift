import SpriteKit

// MARK: - Animation Utilities
struct AnimationUtils {
    
    // MARK: - Color Animation Effects
    static func createGlowEffect(primaryColor: SKColor, secondaryColor: SKColor, duration: TimeInterval = 0.5) -> SKAction {
        return SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(with: primaryColor, colorBlendFactor: 0.5, duration: duration),
            SKAction.colorize(with: secondaryColor, colorBlendFactor: 1.0, duration: duration)
        ]))
    }
    
    static func createFlashEffect(flashColor: SKColor, originalColor: SKColor, duration: TimeInterval = 0.1) -> SKAction {
        return SKAction.sequence([
            SKAction.colorize(with: flashColor, colorBlendFactor: 0.5, duration: duration),
            SKAction.colorize(with: originalColor, colorBlendFactor: 1.0, duration: duration)
        ])
    }
    
    // MARK: - Scale Animation Effects
    static func createPulseEffect(minScale: CGFloat = 1.0, maxScale: CGFloat = 1.2, duration: TimeInterval = 0.2) -> SKAction {
        return SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: maxScale, duration: duration),
            SKAction.scale(to: minScale, duration: duration)
        ]))
    }
    
    static func createScaleUpAndRemove(scale: CGFloat, duration: TimeInterval) -> SKAction {
        let scaleUp = SKAction.scale(to: scale, duration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        
        return SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ])
    }
    
    // MARK: - Fade Animation Effects
    static func createFadeInEffect(duration: TimeInterval = 0.2, initialAlpha: CGFloat = 0.0) -> SKAction {
        return SKAction.sequence([
            SKAction.fadeAlpha(to: initialAlpha, duration: 0),
            SKAction.fadeIn(withDuration: duration)
        ])
    }
    
    static func createFadeOutAndRemove(duration: TimeInterval = 0.3) -> SKAction {
        return SKAction.sequence([
            SKAction.fadeOut(withDuration: duration),
            SKAction.removeFromParent()
        ])
    }
    
    static func createBlinkEffect(minAlpha: CGFloat = 0.5, maxAlpha: CGFloat = 1.0, duration: TimeInterval = 0.2) -> SKAction {
        return SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: minAlpha, duration: duration),
            SKAction.fadeAlpha(to: maxAlpha, duration: duration)
        ]))
    }
    
    // MARK: - Movement Animation Effects
    static func createMoveAndFadeEffect(moveDistance: CGFloat, duration: TimeInterval, direction: Direction = .up) -> SKAction {
        let moveVector: CGVector
        switch direction {
        case .up:
            moveVector = CGVector(dx: 0, dy: moveDistance)
        case .down:
            moveVector = CGVector(dx: 0, dy: -moveDistance)
        case .left:
            moveVector = CGVector(dx: -moveDistance, dy: 0)
        case .right:
            moveVector = CGVector(dx: moveDistance, dy: 0)
        }
        
        let move = SKAction.moveBy(x: moveVector.dx, y: moveVector.dy, duration: duration)
        let fade = SKAction.fadeOut(withDuration: duration)
        
        return SKAction.group([move, fade])
    }
    
    // MARK: - Complex Animation Combinations
    static func createAppearEffect(scale: CGFloat = 0.5, targetScale: CGFloat = 1.0, duration: TimeInterval = 0.2) -> SKAction {
        let scaleUp = SKAction.scale(to: targetScale, duration: duration)
        let fadeIn = createFadeInEffect(duration: duration)
        let moveUp = SKAction.moveBy(x: 0, y: GameConstants.ToastMessage.appearMoveDistance, duration: duration)
        
        return SKAction.group([scaleUp, fadeIn, moveUp])
    }
    
    static func createDisappearEffect(scale: CGFloat = 0.8, duration: TimeInterval = 0.3) -> SKAction {
        let scaleDown = SKAction.scale(to: scale, duration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let moveUp = SKAction.moveBy(x: 0, y: GameConstants.ToastMessage.disappearMoveDistance, duration: duration)
        
        return SKAction.group([scaleDown, fadeOut, moveUp])
    }
}

// MARK: - Direction Enum
enum Direction {
    case up, down, left, right
}
