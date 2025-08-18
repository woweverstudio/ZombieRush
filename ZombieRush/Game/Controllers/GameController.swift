//
//  GameController.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit
import UIKit

class GameController {
    
    // MARK: - Properties
    private weak var scene: GameScene?
    private weak var player: Player?
    
    // MARK: - Touch Tracking
    private var leftTouch: UITouch?
    private var rightTouch: UITouch?
    
    // MARK: - UI Elements
    private var joystickBase: SKShapeNode?
    private var joystickThumb: SKShapeNode?
    private var fireButton: SKShapeNode?
    
    // MARK: - Initialization
    init(scene: GameScene, player: Player) {
        self.scene = scene
        self.player = player
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        guard let scene = scene, let camera = scene.camera else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // 조이스틱 (좌측 하단)
        let joystickX = -screenWidth/2 + 100
        let joystickY = -screenHeight/2 + 100
        
        joystickBase = SKShapeNode(circleOfRadius: 50)
        joystickBase?.fillColor = SKColor.clear
        joystickBase?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        joystickBase?.lineWidth = 2
        joystickBase?.position = CGPoint(x: joystickX, y: joystickY)
        joystickBase?.zPosition = 100
        camera.addChild(joystickBase!)
        
        joystickThumb = SKShapeNode(circleOfRadius: 20)
        joystickThumb?.fillColor = SKColor.white.withAlphaComponent(0.2)
        joystickThumb?.strokeColor = SKColor.white.withAlphaComponent(0.5)
        joystickThumb?.lineWidth = 1.5
        joystickThumb?.position = CGPoint(x: joystickX, y: joystickY)
        joystickThumb?.zPosition = 101
        camera.addChild(joystickThumb!)
        
        // 발사 버튼 (우측 하단)
        let fireX = screenWidth/2 - 100
        let fireY = -screenHeight/2 + 100
        
        // 네모난 불투명 발사버튼
        fireButton = SKShapeNode(rectOf: CGSize(width: 80, height: 80), cornerRadius: 8)
        fireButton?.fillColor = SKColor.white.withAlphaComponent(0.1)
        fireButton?.strokeColor = SKColor.white.withAlphaComponent(0.4)
        fireButton?.lineWidth = 2
        fireButton?.position = CGPoint(x: fireX, y: fireY)
        fireButton?.zPosition = 100
        
        // FIRE 텍스트 추가
        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontName = "Arial-Bold"
        fireLabel.fontSize = 16
        fireLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        fireLabel.horizontalAlignmentMode = .center
        fireLabel.verticalAlignmentMode = .center
        
        fireButton?.addChild(fireLabel)
        
        camera.addChild(fireButton!)
    }
    
    // MARK: - Touch Handling
    func handleTouchBegan(_ touches: Set<UITouch>) {
        guard let scene = scene, let camera = scene.camera else { return }
        
        for touch in touches {
            let location = touch.location(in: camera)
            
            // 조이스틱 영역 체크
            if let joystickBase = joystickBase, leftTouch == nil {
                let distance = hypot(location.x - joystickBase.position.x, location.y - joystickBase.position.y)
                if distance <= 50 {
                    leftTouch = touch
                    continue
                }
            }
            
            // 발사 버튼 영역 체크
            if let fireButton = fireButton, rightTouch == nil {
                let distance = hypot(location.x - fireButton.position.x, location.y - fireButton.position.y)
                if distance <= 40 {
                    rightTouch = touch
                    fireBullet()
                    continue
                }
            }
        }
    }
    
    func handleTouchMoved(_ touches: Set<UITouch>) {
        guard let scene = scene, let camera = scene.camera else { return }
        
        for touch in touches {
            if touch == leftTouch {
                let location = touch.location(in: camera)
                updateJoystick(location: location)
            }
        }
    }
    
    func handleTouchEnded(_ touches: Set<UITouch>) {
        for touch in touches {
            if touch == leftTouch {
                leftTouch = nil
                resetJoystick()
                player?.stopMoving()
            }
            
            if touch == rightTouch {
                rightTouch = nil
                // stopFiring 메서드 제거됨
            }
        }
    }
    
    func handleTouchCancelled(_ touches: Set<UITouch>) {
        handleTouchEnded(touches)
    }
    
    // MARK: - Joystick Logic
    private func updateJoystick(location: CGPoint) {
        guard let joystickBase = joystickBase,
              let joystickThumb = joystickThumb else { return }
        
        let basePos = joystickBase.position
        let deltaX = location.x - basePos.x
        let deltaY = location.y - basePos.y
        let distance = hypot(deltaX, deltaY)
        
        let maxDistance: CGFloat = 30
        if distance > 0 {
            let clampedDistance = min(distance, maxDistance)
            let angle = atan2(deltaY, deltaX)
            
            let thumbX = basePos.x + cos(angle) * clampedDistance
            let thumbY = basePos.y + sin(angle) * clampedDistance
            joystickThumb.position = CGPoint(x: thumbX, y: thumbY)
            
            if distance > 5 {
                let normalizedX = deltaX / distance
                let normalizedY = deltaY / distance
                player?.move(direction: CGVector(dx: normalizedX, dy: normalizedY))
            }
        }
    }
    
    private func resetJoystick() {
        guard let joystickBase = joystickBase,
              let joystickThumb = joystickThumb else { return }
        
        joystickThumb.position = joystickBase.position
    }
    
    // MARK: - Bullet System
    private func fireBullet() {
        guard let scene = scene,
              let player = player,
              let worldNode = scene.childNode(withName: "World") else { return }
        
        // 플레이어가 탄약이 있는지 확인
        guard player.canFire() else { return }
        
        let startPosition = player.position // 플레이어 정확한 중심에서 발사
        
        // 샷건 모드 확인
        if player.getIsShotgunMode() {
            fireShotgunBullets(from: startPosition, worldNode: worldNode)
            // 샷건 모드에서는 탄약 소모 없음
        } else {
            fireSingleBullet(from: startPosition, worldNode: worldNode)
            // 일반 모드에서만 탄약 소모
            player.consumeAmmo()
        }
        
        // 햅틱 피드백
        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
        impactFeedback.impactOccurred()
    }
    
    private func fireSingleBullet(from position: CGPoint, worldNode: SKNode) {
        let bullet = Bullet()
        
        // 자동조준: 가장 가까운 좀비 찾기
        let direction = getAutoAimDirection() ?? CGVector(dx: 0, dy: 1)
        
        // setFireDirection 메서드 제거됨
        
        worldNode.addChild(bullet)
        bullet.fire(from: position, direction: direction)
    }
    
    private func fireShotgunBullets(from position: CGPoint, worldNode: SKNode) {
        guard let player = player else { return }
        
        let bulletCount = player.getShotgunBulletCount()
        let spreadAngle = player.getShotgunSpreadAngle()
        
        // 기본 방향 (자동조준 또는 위쪽)
        let baseDirection = getAutoAimDirection() ?? CGVector(dx: 0, dy: 1)
        let baseAngle = atan2(baseDirection.dy, baseDirection.dx)
        
        // setFireDirection 메서드 제거됨
        
        // 여러 발의 총알을 부채꼴로 발사
        for i in 0..<bulletCount {
            let bullet = Bullet()
            
            // 각도 계산 (중앙을 기준으로 좌우로 분산)
            let angleOffset = (Float(i) - Float(bulletCount - 1) / 2.0) * Float(spreadAngle) / Float(bulletCount - 1)
            let finalAngle = baseAngle + CGFloat(angleOffset * .pi / 180.0)
            
            let direction = CGVector(
                dx: cos(finalAngle),
                dy: sin(finalAngle)
            )
            
            worldNode.addChild(bullet)
            bullet.fire(from: position, direction: direction)
        }
    }
    
    private func getAutoAimDirection() -> CGVector? {
        guard let scene = scene,
              let player = player,
              let camera = scene.camera else { return nil }
        
        // 화면 크기 계산
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // 카메라 기준 화면 범위
        let cameraPos = camera.position
        let screenRect = CGRect(
            x: cameraPos.x - screenWidth/2,
            y: cameraPos.y - screenHeight/2,
            width: screenWidth,
            height: screenHeight
        )
        
        var closestZombie: Zombie?
        var closestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        // 모든 좀비 검사
        scene.enumerateChildNodes(withName: "//Zombie") { node, _ in
            guard let zombie = node as? Zombie else { return }
            
            // 화면 안에 있는 좀비만 고려
            if screenRect.contains(zombie.position) {
                let distance = hypot(
                    zombie.position.x - player.position.x,
                    zombie.position.y - player.position.y
                )
                
                if distance < closestDistance {
                    closestDistance = distance
                    closestZombie = zombie
                }
            }
        }
        
        // 가장 가까운 좀비 방향 계산
        guard let target = closestZombie else { return nil }
        
        let deltaX = target.position.x - player.position.x
        let deltaY = target.position.y - player.position.y
        let distance = hypot(deltaX, deltaY)
        
        if distance > 0 {
            return CGVector(dx: deltaX / distance, dy: deltaY / distance)
        }
        
        return nil
    }
}
