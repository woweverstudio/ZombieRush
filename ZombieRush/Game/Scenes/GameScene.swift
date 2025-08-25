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
    private var hudManager: HUDManager?
    private var zombieSpawnSystem: ZombieSpawnSystem?
    private var toastMessageManager: ToastMessageManager?
    private var itemSpawnSystem: ItemSpawnSystem?
    private var itemEffectSystem: ItemEffectSystem?
    private var meteorSystem: MeteorSystem?
    
    // MARK: - Dependencies
    private let appRouter: AppRouter
    
    // MARK: - Game State
    private let gameStateManager = GameStateManager.shared
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Initialization
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
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
            self?.setupSystems()
            self?.setupController()
            self?.setupHUD()
            self?.setupZombieSpawnSystem()
            self?.setupToastMessageManager()
            self?.setupItemSystem()
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
        hudManager = HUDManager(camera: cameraNode, appRouter: appRouter)
    }
    
    private func setupZombieSpawnSystem() {
        guard let worldNode = worldNode, let player = player else { return }
        zombieSpawnSystem = ZombieSpawnSystem(worldNode: worldNode, player: player)
        
        // 웨이브 시작 콜백 설정
        zombieSpawnSystem?.onNewWaveStarted = { [weak self] waveNumber in
            let message = String(format: TextConstants.Wave.waveAnnouncementFormat, waveNumber)
            self?.toastMessageManager?.showToastMessage(message, duration: GameBalance.Wave.announcementDuration)
            
            // 플레이어 웨이브 속도 보너스 적용
            self?.player?.updateWaveSpeed(currentWave: waveNumber)
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
        itemSpawnSystem = ItemSpawnSystem(worldNode: worldNode)
        
        // 아이템 효과 시스템 설정
        itemEffectSystem = ItemEffectSystem(player: player, toastMessageManager: toastMessageManager)
        
        // 메테오 시스템 설정
        meteorSystem = MeteorSystem(worldNode: worldNode)
        
        // 플레이어에 메테오 시스템 연결
        player.setMeteorSystem(meteorSystem!)
        
        // 아이템 수집 콜백 설정
        itemSpawnSystem?.onItemCollected = { [weak self] itemType in
            self?.itemEffectSystem?.applyItemEffect(type: itemType)
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
        zombieSpawnSystem?.update(currentTime)
        itemSpawnSystem?.update(currentTime)
        meteorSystem?.update(currentTime)
        hudManager?.updateTime()
        
        // 플레이어 상태 업데이트
        updatePlayerHUD()
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 게임오버 상태에서는 터치 처리 안함
        if gameStateManager.isGameOver() {
            return
        }
        
        // HUD 터치 처리 (나가기 버튼 등)
        for touch in touches {
            let location = touch.location(in: cameraNode!)
            if hudManager?.handleTouch(at: location) == true {
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
    
    func removeZombie(_ zombie: Zombie) {
        zombieSpawnSystem?.removeZombie(zombie)
    }
    
    func collectItem(_ item: Item) {
        itemSpawnSystem?.collectItem(item)
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
        
        // 개인 랭크에 현재 게임 기록 저장 및 NEW RECORD 여부 확인
        let isNewRecord = gameStateManager.saveCurrentGameRecordAndCheckNew()
        
        // 라우터를 통해 게임오버 화면으로 전환
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
        // 플레이어 제거
        player?.removeFromParent()
        player = nil
        
        // 좀비 스폰 시스템 정리 (배열에서 제거)
        zombieSpawnSystem?.removeAllZombies()
        
        // 모든 아이템 제거
        itemSpawnSystem?.removeAllItems()
        
        // 모든 아이템 효과 제거
        itemEffectSystem?.removeAllEffects()
        
        // 메테오 정리
        meteorSystem?.clearAllMeteors()
        
        // 월드 노드의 모든 자식 노드 제거 (좀비, 총알, 배경 등 모든 게임 오브젝트)
        worldNode?.removeAllChildren()
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