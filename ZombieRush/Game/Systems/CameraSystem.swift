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
    private var originalCameraScale: CGFloat = 1.2  // 메테오 효과용 원래 줌 상태 저장 (확대된 기본 시야)
    
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

    // MARK: - Game Start Camera Effects
    func performGameStartZoomEffect() {
        guard let camera = camera else { return }

        // 게임 시작 시점의 원래 카메라 스케일 설정 (메테오 효과용)
        // 1.2배 확대된 시야를 기본으로 사용
        if originalCameraScale == 1.2 { // 이미 설정된 경우 유지
            camera.xScale = originalCameraScale
            camera.yScale = originalCameraScale
        }

        // zoomCamera 함수를 사용해서 시퀀스 구현
        // 무조건 전체 맵이 보이도록 크게 줌아웃 (기준 스케일 1.0)
        let zoomOutScale = 2.5

        // 줌아웃 실행
        zoomCamera(to: zoomOutScale, duration: 1.0)

        // 3초 후 줌인 실행 (줌아웃 1초 + 대기 3초)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.zoomCamera(to: self.originalCameraScale, duration: 1.0)
        }
    }

    // MARK: - Meteor Camera Effects
    func startMeteorZoomOut() {
        guard let camera = camera else { return }

        // 메테오 배치 시 줌아웃 시작 - 게임 시작 시 저장된 원래 상태 사용
        // originalCameraScale은 게임 시작 시 한 번만 저장됨
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
