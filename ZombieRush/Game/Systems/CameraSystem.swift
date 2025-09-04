//
//  CameraSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

class CameraSystem {
    
    // MARK: - Properties
    private weak var scene: SKScene?
    private weak var player: Player?
    private weak var camera: SKCameraNode?

    // MARK: - Camera Settings
    private let cameraSmoothness: CGFloat = 0.1
    private var originalCameraScale: CGFloat = 1.0  // 메테오 효과용 원래 줌 상태 저장
    
    // MARK: - Initialization
    init(scene: SKScene, player: Player?, camera: SKCameraNode?) {
        self.scene = scene
        self.player = player
        self.camera = camera
    }
    
    // MARK: - Update
    func update(_ currentTime: TimeInterval) {
        updateCameraPosition()
    }
    
    // MARK: - Camera Movement
    private func updateCameraPosition() {
        guard let player = player, let camera = camera else { return }
        
        // Top-Down View에서는 플레이어 위치에 직접 카메라 위치
        let targetPosition = player.position
        
        // 부드러운 카메라 이동
        let newX = camera.position.x + (targetPosition.x - camera.position.x) * cameraSmoothness
        let newY = camera.position.y + (targetPosition.y - camera.position.y) * cameraSmoothness
        
        camera.position = CGPoint(x: newX, y: newY)
    }
    
    // MARK: - Camera Shake (나중에 사용)
    func shakeCamera(intensity: CGFloat, duration: TimeInterval) {
        guard let camera = camera else { return }
        
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: intensity, y: intensity, duration: 0.05),
            SKAction.moveBy(x: -intensity, y: -intensity, duration: 0.05),
            SKAction.moveBy(x: -intensity, y: intensity, duration: 0.05),
            SKAction.moveBy(x: intensity, y: -intensity, duration: 0.05)
        ])
        
        let repeatAction = SKAction.repeat(shakeAction, count: Int(duration / 0.2))
        camera.run(repeatAction)
    }
    
    // MARK: - Camera Zoom
    func zoomCamera(to scale: CGFloat, duration: TimeInterval) {
        guard let camera = camera else { return }

        let zoomAction = SKAction.scale(to: scale, duration: duration)
        camera.run(zoomAction)
    }

    // MARK: - Meteor Camera Effects
    func startMeteorZoomOut() {
        guard let camera = camera else { return }

        // 메테오 배치 시 줌아웃 시작 - 원래 상태 저장
        originalCameraScale = camera.xScale
        let zoomOut = SKAction.scale(to: originalCameraScale * 1.3, duration: 0.2)
        camera.run(zoomOut)
    }

    func performMeteorExplosionZoomIn() {
        guard let camera = camera else { return }

        // 메테오 폭발 후 1초 뒤 줌인 - 저장된 원래 상태로 복귀
        let wait = SKAction.wait(forDuration: 1.0)
        let zoomIn = SKAction.scale(to: originalCameraScale, duration: 0.4)

        let sequence = SKAction.sequence([wait, zoomIn])
        camera.run(sequence)
    }
}
