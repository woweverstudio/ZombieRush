//
//  GameScene.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    private var player: Player?
    private var cameraNode: SKCameraNode?
    private var worldNode: SKNode?
    
    // MARK: - Game Systems
    private var physicsSystem: PhysicsSystem?
    private var cameraSystem: CameraSystem?
    private var worldManager: WorldManager?
    private var gameController: GameController?
    private var hudManager: HUDManager?
    private var zombieSpawner: ZombieSpawner?
    private var gameOverManager: GameOverManager?
    private var toastMessageManager: ToastMessageManager?
    private var itemSpawner: ItemSpawner?
    private var itemEffectManager: ItemEffectManager?
    private var meteorSystem: MeteorSystem?
    
    // MARK: - Game State
    private let gameStateManager = GameStateManager.shared
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        // 멀티터치 활성화
        view.isMultipleTouchEnabled = true
        
        // 게임 시작
        gameStateManager.startNewGame()
        
        // 텍스처 캐시 제거됨
        
        setupPhysicsWorld()
        setupWorld()
        setupPlayer()
        setupCamera()
        setupSystems()
        setupController()
        setupHUD()
        setupZombieSpawner()
        setupGameOverManager()
        setupToastMessageManager()
        setupItemSystem()
    }
    
    // MARK: - Setup Methods
    private func setupPhysicsWorld() {
        // Top-Down View에서는 중력 없음
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // 물리 월드 경계 설정 (넓은 맵을 위해)
        let worldSize = CGSize(width: GameConstants.Physics.worldWidth, height: GameConstants.Physics.worldHeight)
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: -worldSize.width/2, y: -worldSize.height/2), size: worldSize))
        borderBody.categoryBitMask = PhysicsCategory.worldBorder
        borderBody.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        borderBody.contactTestBitMask = PhysicsCategory.none
        borderBody.friction = 0
        borderBody.restitution = 0
        borderBody.isDynamic = false
        self.physicsBody = borderBody
    }
    
    private func setupWorld() {
        worldNode = SKNode()
        worldNode?.name = GameConstants.NodeNames.world
        addChild(worldNode!)
        
        // WorldManager를 사용하여 월드 설정
        worldManager = WorldManager(worldNode: worldNode!)
        worldManager?.setupWorld()
    }
    
    private func setupPlayer() {
        guard let worldManager = worldManager else { return }
        
        player = Player()
        player?.position = CGPoint(x: 0, y: 0)
        worldManager.addChild(player!)
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode?.name = GameConstants.NodeNames.camera
        addChild(cameraNode!)
        
        // scene의 camera 속성 설정
        self.camera = cameraNode
        
        // 카메라를 플레이어에 연결
        if let player = player {
            cameraNode?.position = player.position
        }
        

    }
    
    private func setupSystems() {
        physicsSystem = PhysicsSystem(scene: self)
        cameraSystem = CameraSystem(scene: self, player: player, camera: cameraNode)
    }
    
    private func setupController() {
        guard let player = player else { return }
        gameController = GameController(scene: self, player: player)
    }
    
    private func setupHUD() {
        guard let cameraNode = cameraNode else { return }
        hudManager = HUDManager(camera: cameraNode)
    }
    
    private func setupZombieSpawner() {
        guard let worldNode = worldNode, let player = player else { return }
        zombieSpawner = ZombieSpawner(worldNode: worldNode, player: player)
        
        // 웨이브 시작 콜백 설정
        zombieSpawner?.onNewWaveStarted = { [weak self] waveNumber in
            let message = String(format: GameConstants.Text.waveAnnouncement, waveNumber)
            self?.toastMessageManager?.showToastMessage(message, duration: GameConstants.Wave.announcementDuration)
            
            // 플레이어 웨이브 속도 보너스 적용
            self?.player?.updateWaveSpeed(currentWave: waveNumber)
        }
    }
    
    private func setupGameOverManager() {
        guard let cameraNode = cameraNode else { return }
        
        gameOverManager = GameOverManager(camera: cameraNode)
        
        // 다시하기 콜백
        gameOverManager?.onRestart = { [weak self] in
            self?.restartGame()
        }
        
        // 그만하기 콜백
        gameOverManager?.onQuit = { [weak self] in
            self?.quitGame()
        }
    }
    
    private func setupToastMessageManager() {
        guard let cameraNode = cameraNode, let player = player else { return }
        toastMessageManager = ToastMessageManager(camera: cameraNode, player: player)
    }
    
    private func setupItemSystem() {
        guard let worldNode = worldNode, 
              let player = player,
              let toastMessageManager = toastMessageManager else { 
                        return
        }
        
        // 아이템 스포너 설정
        itemSpawner = ItemSpawner(worldNode: worldNode)
        
        // 아이템 효과 매니저 설정
        itemEffectManager = ItemEffectManager(player: player, toastMessageManager: toastMessageManager)
        
        // 메테오 시스템 설정
        meteorSystem = MeteorSystem(worldNode: worldNode, player: player)
        
        // 아이템 수집 콜백 설정
        itemSpawner?.onItemCollected = { [weak self] itemType in
            self?.itemEffectManager?.applyItemEffect(type: itemType)
            
            // 메테오 아이템인 경우 메테오 스톰 시작
            if itemType == .meteor {
                self?.meteorSystem?.startMeteorStorm()
            }
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // 첫 프레임에서 lastUpdateTime 초기화
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // 델타타임 계산
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // 게임오버 상태에서는 업데이트 중지
        if gameStateManager.isGameOver() {
            return
        }
        
        // 플레이어 사망 체크
        if let player = player, player.isDead() {
            triggerGameOver()
            return
        }
        
        // 게임 시간 업데이트 (델타타임 사용)
        gameStateManager.updatePlayTime(deltaTime: deltaTime)
        
        // 시스템 업데이트
        physicsSystem?.update(currentTime)
        cameraSystem?.update(currentTime)
        zombieSpawner?.update(currentTime)
        itemSpawner?.update(currentTime)
        meteorSystem?.update(currentTime)
        hudManager?.updateTime()
        
        // 플레이어 상태 업데이트
        updatePlayerHUD()
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 게임오버 상태에서는 게임오버 UI만 처리
        if gameStateManager.isGameOver() {
            for touch in touches {
                let location = touch.location(in: cameraNode!)
                if gameOverManager?.handleTouch(at: location) == true {
                    return
                }
            }
            return
        }
        
        gameController?.handleTouchBegan(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStateManager.isGameOver() { return }
        gameController?.handleTouchMoved(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStateManager.isGameOver() { return }
        gameController?.handleTouchEnded(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStateManager.isGameOver() { return }
        gameController?.handleTouchCancelled(touches)
    }
    
    // MARK: - Game Logic
    func addScore(_ points: Int = GameConstants.Balance.scorePerKill) {
        gameStateManager.addScore(points)
        hudManager?.addScore(points)
    }
    
    func removeZombie(_ zombie: Zombie) {
        zombieSpawner?.removeZombie(zombie)
    }
    
    func collectItem(_ item: Item) {
        itemSpawner?.collectItem(item)
    }
    
    func handleMeteorCollision(meteor: Meteor, zombie: Zombie) {
        let isDead = meteorSystem?.handleMeteorCollision(meteor: meteor, zombie: zombie) ?? false
        
        if isDead {
            // 점수 추가
            addScore()
            
            // 좀비 스포너에서 제거
            removeZombie(zombie)
        }
    }
    
    private func updatePlayerHUD() {
        guard let player = player, let hudManager = hudManager else { return }
        
        hudManager.updatePlayerStats(
            health: player.getHealth(),
            maxHealth: player.getMaxHealth(),
            ammo: player.getAmmo(),
            maxAmmo: player.getMaxAmmo(),
            isReloading: player.getIsReloading()
        )
    }
    
    // MARK: - Game Over Logic
    private func triggerGameOver() {
        guard !gameStateManager.isGameOver() else { return }
        
        // 게임 상태를 게임오버로 변경
        gameStateManager.endGame()
        
        // 모든 UI 숨기기 (SOLID 원칙 - 단일 책임)
        hideAllGameUI()
        
        // 게임 통계 가져오기
        let playTime = gameStateManager.getPlayTime()
        let score = gameStateManager.getScore()
        let wave = gameStateManager.getCurrentWave()
        
        // 맵의 모든 게임 노드 제거
        clearGameNodes()
        
        // 게임오버 화면 표시
        gameOverManager?.showGameOver(playTime: playTime, score: score, wave: wave)
    }
    
    private func clearGameNodes() {
        // 플레이어 제거
        player?.removeFromParent()
        player = nil
        
        // 좀비 스포너 정리 (배열에서 제거)
        zombieSpawner?.removeAllZombies()
        
        // 모든 아이템 제거
        itemSpawner?.removeAllItems()
        
        // 모든 아이템 효과 제거
        itemEffectManager?.removeAllEffects()
        
        // 메테오 정리
        meteorSystem?.stopMeteorStorm()
        
        // 월드 노드의 모든 자식 노드 제거 (좀비, 총알, 배경 등 모든 게임 오브젝트)
        worldNode?.removeAllChildren()
    }
    
    private func restartGame() {
        // 게임오버 UI 숨기기
        gameOverManager?.hideGameOver()
        
        // 게임 UI 다시 보이기 (재시작 시 UI 복원)
        showAllGameUI()
        
        // 게임 재시작 시 게임 BGM 재생
        AudioManager.shared.playGameMusic()
        
        // 씬 다시 로드
        let scene = GameScene(size: self.size)
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene)
    }
    
    private func quitGame() {
        // 게임 뷰 닫기 (GameView에서 처리하도록 알림)
        NotificationCenter.default.post(name: NSNotification.Name(GameConstants.Notifications.quitGame), object: nil)
    }
    
    // MARK: - UI Control (SOLID 원칙 - 단일 책임)
    private func hideAllGameUI() {
        gameController?.hideUI()
        hudManager?.hideHUD()
    }
    
    private func showAllGameUI() {
        gameController?.showUI()
        hudManager?.showHUD()
    }
}