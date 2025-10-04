//
//  Nuclear.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class Nuclear {
    // MARK: - Nuclear Explosion Effects

    /// 핵폭발 메인 효과 생성
    static func createNuclearExplosion(at position: CGPoint, in scene: SKScene) {
        let explosionNode = SKNode()
        explosionNode.position = position
        scene.addChild(explosionNode)

        // 1. 외부 빨간색 채워진 원
        let outerRing = SKShapeNode(circleOfRadius: 800)
        outerRing.fillColor = UIColor.red
        outerRing.strokeColor = .clear
        outerRing.alpha = 0.6
        explosionNode.addChild(outerRing)

        // 2. 중간 주황색 채워진 원
        let middleRing = SKShapeNode(circleOfRadius: 500)
        middleRing.fillColor = UIColor.orange
        middleRing.strokeColor = .clear
        middleRing.alpha = 0.7
        explosionNode.addChild(middleRing)

        // 3. 내부 흰색 채워진 원
        let innerRing = SKShapeNode(circleOfRadius: 300)
        innerRing.fillColor = UIColor.white
        innerRing.strokeColor = .clear
        innerRing.alpha = 0.8
        explosionNode.addChild(innerRing)

        // 간단한 확장 애니메이션
        let scaleUp = SKAction.scale(to: 1.2, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()

        explosionNode.run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
    }

    /// 좀비 폭발 효과 생성
    static func createZombieExplosionEffect(at position: CGPoint, in scene: SKScene) {
        guard scene.parent != nil else {
            return
        }

        let effectNode = SKNode()
        effectNode.position = position
        scene.addChild(effectNode)

        // 간단한 작은 폭발 효과
        let explosion = SKShapeNode(circleOfRadius: 20)
        explosion.fillColor = UIColor.orange
        explosion.strokeColor = UIColor.red
        explosion.lineWidth = 2
        explosion.alpha = 0.8
        effectNode.addChild(explosion)

        // 간단한 애니메이션
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()

        effectNode.run(SKAction.sequence([
            SKAction.group([scaleUp, fadeOut]),
            remove
        ]))
    }

    /// 핵폭발 사운드 재생
    static func playNuclearSound(in scene: SKScene) {
        if AudioManager.shared.isSoundEffectsEnabled {
            AudioManager.shared.playSoundEffect("nuclear.wav")
        }
    }
}
