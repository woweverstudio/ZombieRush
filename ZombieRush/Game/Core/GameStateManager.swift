import Foundation

// MARK: - Game State Enum
enum GameState {
    case playing
    case gameOver
    case loading
}

// MARK: - Game State Manager
class GameStateManager {
    var points: Int = 0
    var Kills: Int = 0
    var playTime: TimeInterval = 0
    var currentWave: Int = 1  // 웨이브는 1부터 시작
    
    // MARK: - Properties
    private(set) var currentState: GameState = .loading
    private(set) var isAppActive: Bool = true  // 앱 활성 상태 추적

    
    // MARK: - Wave System
    private var currentWaveNumber: Int = 1
    private var previousWaveNumber: Int = 1  // 이전 프레임의 웨이브 번호
    
    
    // MARK: - State Management
    init() {}
    
    // MARK: - Public Methods
    func startNewGame() {
        // 게임 상태 초기화
        reset()

        currentState = .playing
    }
    
    func reset() {
        points = 0
        Kills = 0
        playTime = 0
        currentWave = 1  // 웨이브는 1부터 시작
        
        // 웨이브 시스템 초기화
        currentWaveNumber = 1
        previousWaveNumber = 1
        currentWave = currentWaveNumber
    }
    
    func endGame() {
        currentState = .gameOver
    }
    
    func isGameActive() -> Bool {
        return currentState == .playing
    }
    
    func isGameOver() -> Bool {
        return currentState == .gameOver
    }
    
    // 앱 활성 상태 확인 메소드
    func isAppCurrentlyActive() -> Bool {
        return isAppActive
    }
    
    // MARK: - Statistics Management
    func addScore(_ points: Int = GameBalance.Score.perKill) {
        guard isGameActive() else { return }
        self.points += points
    }
    
    func updatePlayTime(deltaTime: TimeInterval) {
        // 앱이 비활성 상태이거나 게임이 일시정지된 경우 시간 업데이트 중지
        guard isGameActive() && isAppActive else { return }
        self.playTime += deltaTime
    }
    
    func getScore() -> Int {
        return self.points
    }
    
    func getZombieKills() -> Int {
        return self.Kills
    }
    
    func getPlayTime() -> TimeInterval {
        return self.playTime
    }
    
    func getCurrentWave() -> Int {
        return self.currentWave
    }
    
    // MARK: - Wave Management
    func updateWaveSystem(currentTime: TimeInterval) -> Bool {
        guard isGameActive() else { return false }
        
        // playTime을 기준으로 현재 웨이브 계산
        let waveDuration = GameBalance.Wave.duration
        let calculatedWave = Int(playTime / waveDuration) + 1
        
        // 계산된 웨이브가 현재 웨이브보다 크면 웨이브 상승
        if calculatedWave > currentWaveNumber {
            previousWaveNumber = currentWaveNumber
            currentWaveNumber = calculatedWave
            currentWave = currentWaveNumber
            
            return true  // 새로운 웨이브 시작됨
        }
        
        return false
    }
    
    func getCurrentWaveNumber() -> Int {
        return currentWaveNumber
    }
    
    func getWaveProgress(currentTime: TimeInterval) -> Float {
        // 현재 웨이브 내에서의 진행도 계산
        let waveDuration = GameBalance.Wave.duration
        let playTimeInCurrentWave = playTime.truncatingRemainder(dividingBy: waveDuration)
        return Float(playTimeInCurrentWave / waveDuration)
    }
    
    // MARK: - App State Management
    func setAppActive(_ active: Bool) {
        isAppActive = active
    }
}
