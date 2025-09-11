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
    private let gameStateManager: GameStateManager
    
    // MARK: - Touch Tracking
    private var leftTouch: UITouch?
    private var leftTouchStartLocation: CGPoint?  // 터치 시작 위치 저장
    
    // MARK: - UI Elements
    private var joystickBase: SKShapeNode?
    private var joystickThumb: SKShapeNode?
    
    // MARK: - Joystick System
    private var fixedJoystickPosition: CGPoint = .zero
    private var isUsingTemporaryJoystick: Bool = false
    
    // MARK: - Cached Properties (성능 최적화)
    private let screenBounds: CGSize = UIScreen.main.bounds.size

    // MARK: - Auto Fire System
    private var lastAutoFireTime: TimeInterval = 0
    
    private lazy var leftBottomTouchArea: CGRect = {
        CGRect(
            x: -screenBounds.width / 2,
            y: -screenBounds.height / 2,
            width: screenBounds.width / 2,
            height: screenBounds.height / 2
        )
    }()
    
    private var camera: SKCameraNode? {
        scene?.camera
    }
    
    // MARK: - Constants
    struct Constants {
        static let joystickTouchRadius: CGFloat = 20
        static let joystickMaxDistance: CGFloat = 30
        static let joystickDeadzone: CGFloat = 5
        static let animationDuration: TimeInterval = 0.3
        static let quickAnimationDuration: TimeInterval = 0.2

        struct Colors {
            static let joystickBase = SKColor.white.withAlphaComponent(0.3)
            static let joystickThumbFill = SKColor.white.withAlphaComponent(0.2)
            static let joystickThumbStroke = SKColor.white.withAlphaComponent(0.5)
        }
    }
    
    // MARK: - Initialization
    init(scene: GameScene, player: Player, gameStateManager: GameStateManager) {
        self.scene = scene
        self.player = player
        self.gameStateManager = gameStateManager
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        guard let camera = camera else { return }

        setupJoystick(in: camera)
    }
    
    private func setupJoystick(in camera: SKCameraNode) {
        fixedJoystickPosition = CGPoint(
            x: -screenBounds.width / 2 + UIConstants.Layout.controlMargin,
            y: -screenBounds.height / 2 + UIConstants.Layout.controlMargin
        )
        
        joystickBase = createJoystickBase()
        joystickThumb = createJoystickThumb()
        
        [joystickBase, joystickThumb].forEach { camera.addChild($0!) }
    }

    private func createJoystickBase() -> SKShapeNode {
        let base = SKShapeNode(circleOfRadius: UIConstants.Controls.joystickRadius)
        base.fillColor = .clear
        base.strokeColor = Constants.Colors.joystickBase
        base.lineWidth = 2
        base.position = fixedJoystickPosition
        base.zPosition = UIConstants.Controls.controlZPosition
        return base
    }
    
    private func createJoystickThumb() -> SKShapeNode {
        let thumb = SKShapeNode(circleOfRadius: UIConstants.Controls.joystickThumbRadius)
        thumb.fillColor = Constants.Colors.joystickThumbFill
        thumb.strokeColor = Constants.Colors.joystickThumbStroke
        thumb.lineWidth = 1.5
        thumb.position = fixedJoystickPosition
        thumb.zPosition = 101
        return thumb
    }
    
    
    // MARK: - Touch Handling
    func handleTouchBegan(_ touches: Set<UITouch>) {
        guard let camera = camera else { return }
        
        for touch in touches {
            let location = touch.location(in: camera)

            handleJoystickTouch(touch, at: location)
        }
    }
    
    
    private func handleJoystickTouch(_ touch: UITouch, at location: CGPoint) {
        guard leftTouch == nil, leftBottomTouchArea.contains(location) else { return }

        leftTouch = touch
        leftTouchStartLocation = location  // 터치 시작 위치 저장

        let distanceFromFixed = location.distance(to: fixedJoystickPosition)
        if distanceFromFixed <= UIConstants.Controls.joystickRadius + Constants.joystickTouchRadius {
            isUsingTemporaryJoystick = false
        } else {
            isUsingTemporaryJoystick = true
        }
    }
    
    func handleTouchMoved(_ touches: Set<UITouch>) {
        guard let camera = camera else { return }

        for touch in touches where touch == leftTouch {
            updateJoystick(location: touch.location(in: camera))
        }
    }
    
    func handleTouchEnded(_ touches: Set<UITouch>) {
        for touch in touches {
            if touch == leftTouch {
                leftTouch = nil
                leftTouchStartLocation = nil  // 터치 시작 위치 초기화
                returnJoystickToFixed()
                player?.stopMoving()
            }
        }
    }
    
    func handleTouchCancelled(_ touches: Set<UITouch>) {
        handleTouchEnded(touches)
    }
    
    // MARK: - Joystick Logic
    private func updateJoystick(location: CGPoint) {
        guard let joystickBase = joystickBase,
              let joystickThumb = joystickThumb,
              let touchStartLocation = leftTouchStartLocation else { return }

        // 플레이어 이동 방향 계산 (터치 시작 위치 기준)
        let movementDelta = location - touchStartLocation
        let movementDistance = movementDelta.magnitude

        guard movementDistance > 0 else { return }

        let movementDirection = movementDelta.normalized

        // 썸의 시각적 위치 계산 (베이스 위치 기준)
        let delta = location - joystickBase.position
        let distance = delta.magnitude
        let clampedDistance = min(distance, Constants.joystickMaxDistance)
        let direction = delta.normalized

        joystickThumb.position = joystickBase.position + direction * clampedDistance

        // 플레이어 이동
        if movementDistance > Constants.joystickDeadzone {
            player?.move(direction: CGVector(dx: movementDirection.x, dy: movementDirection.y))
        }
    }

    private func returnJoystickToFixed() {
        guard let joystickThumb = joystickThumb else { return }

        // 썸을 중앙으로 복귀
        let moveThumbAction = SKAction.move(to: fixedJoystickPosition, duration: Constants.quickAnimationDuration)
        joystickThumb.run(moveThumbAction)

        isUsingTemporaryJoystick = false
    }
    
    // MARK: - Auto Fire System
    func updateAutoFire(_ currentTime: TimeInterval, zombies: [Zombie]) {
        guard !findZombiesInCameraView(zombies).isEmpty else { return }

        let currentWave = getCurrentWaveNumber()
        let fireRateDecrement = Double(currentWave - 1) * GameBalance.Bullet.autoFireRateDecrement
        let adjustedFireRate = max(GameBalance.Bullet.autoFireBaseRate - fireRateDecrement, GameBalance.Bullet.autoFireMinRate)

        if currentTime - lastAutoFireTime >= adjustedFireRate {
            fireBullet()
            lastAutoFireTime = currentTime
        }
    }

    // 카메라 뷰 내 좀비 찾기 (자동 조준과 동일한 로직)
    private func findZombiesInCameraView(_ zombies: [Zombie]) -> [Zombie] {
        let screenRect = calculateScreenRect()
        return zombies.filter { zombie in
            screenRect.contains(zombie.position)
        }
    }

    // 카메라 뷰 사각형 계산 (공통 함수)
    private func calculateScreenRect() -> CGRect {
        guard let camera = camera else { return .zero }

        return CGRect(
            origin: camera.position - CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2),
            size: screenBounds
        )
    }

    private func getCurrentWaveNumber() -> Int {
        // 실제 GameStateManager에서 현재 웨이브 가져오기
        return gameStateManager.getCurrentWaveNumber()
    }

    // MARK: - Bullet System
    private func fireBullet() {
        guard let scene = scene,
              let player = player,
              let worldNode = scene.childNode(withName: "World"),
              player.canFire() else { return }

        let startPosition = player.position

        if player.getIsShotgunMode() {
            fireShotgunBullets(from: startPosition, worldNode: worldNode)
            playSound(ResourceConstants.Audio.SoundEffects.shotgun)
            HapticManager.shared.playShotgunHaptic()
            player.consumeAmmo()
        } else {
            fireSingleBullet(from: startPosition, worldNode: worldNode)
            playSound(ResourceConstants.Audio.SoundEffects.shoot)
            HapticManager.shared.playShootHaptic()
            player.consumeAmmo()
        }
    }

    private func fireSingleBullet(from position: CGPoint, worldNode: SKNode) {
        let direction = getAutoAimDirection() ?? CGVector(dx: 0, dy: 1)

        // Bullet의 스마트 생성 메서드 사용 (GameScene 종속성 제거)
        _ = Bullet.fireSingle(from: position, direction: direction, in: worldNode)
    }
    
    private func fireShotgunBullets(from position: CGPoint, worldNode: SKNode) {
        guard let player = player else { return }

        let bulletCount = player.getShotgunBulletCount()
        let spreadAngle = player.getShotgunSpreadAngle()
        let baseDirection = getAutoAimDirection() ?? CGVector(dx: 0, dy: 1)

        // 샷건 총알들 발사
        _ = Bullet.fireShotgun(count: bulletCount,
                          from: position,
                          baseDirection: baseDirection,
                          spreadAngle: spreadAngle,
                          in: worldNode)
    }

    private func getAutoAimDirection() -> CGVector? {
        guard let scene = scene, let player = player else {
            return nil
        }

        let screenRect = calculateScreenRect()
        var closestZombie: Zombie?
        var closestDistance: CGFloat = .greatestFiniteMagnitude

        // 카메라 뷰 내에서 가장 가까운 좀비 찾기
        scene.enumerateChildNodes(withName: "//" + TextConstants.NodeNames.zombie) { node, _ in
            guard let zombie = node as? Zombie else {
                return
            }

            guard screenRect.contains(zombie.position) else {
                return
            }

            let distance = zombie.position.distance(to: player.position)
            if distance < closestDistance {
                closestDistance = distance
                closestZombie = zombie
            }
        }

        guard let target = closestZombie else { return nil }
        return (target.position - player.position).normalized.cgVector
    }
    
    private func playSound(_ soundName: String) {
        guard AudioManager.shared.isSoundEffectsEnabled,
              let scene = scene else { return }
        
        scene.run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
    }
    
    // MARK: - UI Visibility Control
    func hideUI() {
        [joystickBase, joystickThumb].forEach { $0?.isHidden = true }
    }

    func showUI() {
        [joystickBase, joystickThumb].forEach { $0?.isHidden = false }
    }
}

// MARK: - Extensions
private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        hypot(x - point.x, y - point.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    var magnitude: CGFloat {
        hypot(x, y)
    }
    
    var normalized: CGPoint {
        let mag = magnitude
        return mag > 0 ? CGPoint(x: x / mag, y: y / mag) : .zero
    }
    
    var cgVector: CGVector {
        CGVector(dx: x, dy: y)
    }
}

