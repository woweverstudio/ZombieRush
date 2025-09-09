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
    private var worldSystem: WorldSystem?
    private var gameController: GameController?
    private var ultimateController: UltimateController?
    private var hudManager: HUDManager?
    private var zombieSpawnSystem: ZombieSpawnSystem?
    private var toastMessageManager: ToastMessageManager?
    private var itemSpawnSystem: ItemSpawnSystem?
    private var itemEffectSystem: ItemEffectSystem?
    private var ultimateSkill: UltimateSkill
    
    // MARK: - Dependencies
    private let appRouter: AppRouter
    
    // MARK: - Game State
    private let gameStateManager = GameStateManager.shared
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Initialization
    init(appRouter: AppRouter, ultimateSkill: UltimateSkill) {
        self.appRouter = appRouter
        self.ultimateSkill = ultimateSkill
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        // 멀티터치 활성화
        view.isMultipleTouchEnabled = true
        
        // 게임 시작 (GameStateManager가 이미 완벽한 초기화 제공)
        gameStateManager.startNewGame()

        // 게임 시스템 초기화
        initializeGameSystems()
    }
    
    // MARK: - Game System Initialization
    private func initializeGameSystems() {
        // 핵심 시스템들 먼저 초기화 (즉시 필요한 것들)
        setupPhysicsWorld()
        setupWorld()
        setupPlayer()
        setupCamera()
        
        // UI와 상호작용 시스템들을 다음 프레임에서 초기화 (부드러운 시작)
        DispatchQueue.main.async { [weak self] in
            self?.setupPhysicsSystem()
            self?.setupCameraSystem()
            self?.setupUltimateController()  // HUD 바로 뒤로 이동
            self?.setupController()
            self?.setupHUD()
            self?.setupZombieSpawnSystem()
            self?.setupToastMessageManager()
            self?.setupItemSystem()
            self?.setupUltimateSkill() // 제일 마지막 호출해야함

            // 모든 시스템 초기화 완료 후 게임 시작 처리
            self?.startGame()
        }
    }
    
    // MARK: - Game Start
    private func startGame() {
        // 줌아웃 효과 적용
        cameraSystem?.performGameStartZoomEffect()

        // 줌아웃 효과 완료 후 게임 시작 메시지 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let message = NSLocalizedString("GAME_START_MESSAGE", comment: "Game Start Message")
            self?.toastMessageManager?.showToastMessage(message, duration: 4.0)
        }
    }

    // MARK: - Setup Methods
    private func setupPhysicsWorld() {
        // Top-Down View에서는 중력 없음
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // 물리 월드 경계 설정 (넓은 맵을 위해)
        let worldSize = CGSize(width: GameBalance.Physics.worldWidth, height: GameBalance.Physics.worldHeight)
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
        worldNode?.name = TextConstants.NodeNames.world
        addChild(worldNode!)
        
        // WorldSystem을 사용하여 월드 설정
        worldSystem = WorldSystem(worldNode: worldNode!)
        worldSystem?.setupWorld()
    }
    
    private func setupPlayer() {
        guard let worldSystem = worldSystem else { return }

        player = Player()
        player?.position = CGPoint(x: 0, y: 0)
        worldSystem.getWorldNode()?.addChild(player!)

    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode?.name = TextConstants.NodeNames.camera
        addChild(cameraNode!)

        self.camera = cameraNode

        // 카메라를 플레이어에 연결
        if let player = player {
            cameraNode?.position = player.position
        }
    }
    
    private func setupPhysicsSystem() {
        physicsSystem = PhysicsSystem(scene: self)

        // PhysicsSystem 콜백 설정
        physicsSystem?.onPlayerDied = { [weak self] in
            self?.triggerGameOver()
        }
    }
    
    private func setupCameraSystem() {
        guard let player, let cameraNode else { return }
        
        cameraSystem = CameraSystem(scene: self, player: player, camera: cameraNode)
    }

    private func setupController() {
        guard let player else { return }
        gameController = GameController(scene: self, player: player)
    }
    
    private func setupUltimateController() {
        guard let player, let cameraNode else { return }

        ultimateController = UltimateController(scene: self, cameraNode: cameraNode, player: player, skill: ultimateSkill)
    }

    private func setupUltimateSkill() {
        switch self.ultimateSkill {
        case let skill as NuclearAttackSkill:
            skill.scene = self
            skill.cameraSystem = cameraSystem
            skill.toastMessageManager = toastMessageManager
            skill.zombieSpawnSystem = zombieSpawnSystem

            // 콜백 설정 - 점수 증가만 처리
            skill.onZombieKilled = { [weak self] zombie in
                guard let self = self else { return }

                // 점수 증가
                self.addScore()
            }
        default:
            return
        }
    }
    
    private func setupHUD() {
        guard let cameraNode else { return }
        hudManager = HUDManager(camera: cameraNode, appRouter: appRouter)
    }
    
    private func setupZombieSpawnSystem() {
        guard let worldNode , let player else { return }
        zombieSpawnSystem = ZombieSpawnSystem(worldNode: worldNode, player: player)

        // 웨이브 시작 콜백 설정
        zombieSpawnSystem?.onNewWaveStarted = { [weak self] waveNumber in
            let message = String(format: TextConstants.Wave.waveAnnouncementFormat, waveNumber)
            self?.toastMessageManager?.showToastMessage(message, duration: GameBalance.Wave.announcementDuration)
            self?.player?.updateWaveSpeed(currentWave: waveNumber)
        }
    }

    private func setupToastMessageManager() {
        guard let cameraNode, let player else { return }
        toastMessageManager = ToastMessageManager(camera: cameraNode, player: player)
    }
    
    private func setupItemSystem() {
        guard let worldNode, let player, let toastMessageManager else { return }
        
        // 아이템 스포너 설정
        itemSpawnSystem = ItemSpawnSystem(worldNode: worldNode)
        
        // 아이템 효과 시스템 설정
        itemEffectSystem = ItemEffectSystem(player: player, toastMessageManager: toastMessageManager)
        
        // 아이템 수집 콜백 설정
        itemSpawnSystem?.onItemCollected = { [weak self] itemType in
            self?.itemEffectSystem?.applyItemEffect(type: itemType)
        }
    }
    
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        var deltaTime = currentTime - lastUpdateTime
        let maxDeltaTime: TimeInterval = 1.0
        deltaTime = min(deltaTime, maxDeltaTime)

        if gameStateManager.isAppCurrentlyActive() {
            lastUpdateTime = currentTime
        }

        if gameStateManager.isGameOver() {
            return
        }

        // 플레이 시간 업데이트
        gameStateManager.updatePlayTime(deltaTime: deltaTime)

        if gameStateManager.isAppCurrentlyActive() {
            physicsSystem?.update(currentTime)
            cameraSystem?.update(currentTime)
            zombieSpawnSystem?.update(currentTime)
            itemSpawnSystem?.update(currentTime)
            hudManager?.updateTime()

            // 자동 발사 시스템 업데이트
            if let zombies = zombieSpawnSystem?.getZombies() {
                gameController?.updateAutoFire(currentTime, zombies: zombies)
            }
        }

        // 플레이어 상태 업데이트
        if let player = player, let hudManager = hudManager {
            let health = player.getHealth()
            let maxHealth = player.getMaxHealth()
            let ammo = player.getAmmo()
            let maxAmmo = player.getMaxAmmo()
            let isReloading = player.getIsReloading()

            hudManager.updateHUD(health: health, maxHealth: maxHealth,
                               ammo: ammo, maxAmmo: maxAmmo,
                               isReloading: isReloading)
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStateManager.isGameOver() {
            return
        }

        // HUD 터치 처리
        for touch in touches {
            let location = touch.location(in: cameraNode!)
            if hudManager?.handleTouch(at: location) == true {
                return
            }

            // Ultimate 버튼 터치 처리
            if ultimateController?.handleTouch(at: location) == true {
                return
            }
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
    func addScore(_ points: Int = GameBalance.Score.perKill) {
        gameStateManager.addScore(points)
        hudManager?.addScore(points)
    }

    func addUltimateRange() {
        ultimateController?.onZombieAttacked()
    }
    
    func removeZombie(_ zombie: Zombie) {
        zombieSpawnSystem?.removeZombie(zombie)
    }
    
    func collectItem(_ item: Item) {
        itemSpawnSystem?.collectItem(item)
    }
    
    // MARK: - Game Over Logic
    private func triggerGameOver() {
        guard !gameStateManager.isGameOver() else { return }
        
        gameStateManager.endGame()
        hideAllGameUI()
        clearGameNodes()

        let playTime = gameStateManager.getPlayTime()
        let score = gameStateManager.getScore()
        let wave = gameStateManager.getCurrentWave()
        let isNewRecord = gameStateManager.saveCurrentGameRecordAndCheckNew()

        DispatchQueue.main.async { [weak self] in
            self?.appRouter.showGameOver(
                playTime: playTime,
                score: score,
                wave: wave,
                isNewRecord: isNewRecord
            )
        }
    }

    private func clearGameNodes() {
        player?.removeFromParent()
        player = nil

        // 각 시스템이 스스로 정리하도록 위임
        zombieSpawnSystem?.removeAllZombies()
        itemSpawnSystem?.removeAllItems()
        itemEffectSystem?.removeAllEffects()

        // World 노드 정리
        worldNode?.removeAllChildren()
    }
    
    // MARK: - UI Control
    private func hideAllGameUI() {
        gameController?.hideUI()
        hudManager?.hideHUD()
    }
}
