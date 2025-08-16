import Foundation

// MARK: - Game State Enum
enum GameState {
    case playing
    case gameOver
    case loading
}

// MARK: - Game Statistics
struct GameStatistics {
    var score: Int = 0
    var zombieKills: Int = 0
    var playTime: TimeInterval = 0
    var currentWave: Int = 0
    
    mutating func reset() {
        score = 0
        zombieKills = 0
        playTime = 0
        currentWave = 0
    }
    
    mutating func updatePlayTime(deltaTime: TimeInterval) {
        playTime += deltaTime
    }
    
    mutating func addScore(_ points: Int = GameConstants.Balance.scorePerKill) {
        score += points
        zombieKills += 1
    }
}

// MARK: - Game State Manager
class GameStateManager {
    
    // MARK: - Singleton
    static let shared = GameStateManager()
    
    // MARK: - Properties
    private(set) var currentState: GameState = .loading
    private(set) var statistics = GameStatistics()
    
    // MARK: - Wave System
    private var waveStartTime: TimeInterval = 0
    private var currentWaveNumber: Int = 1
    
    // MARK: - State Management
    private init() {}
    
    // MARK: - Public Methods
    func startNewGame() {
        currentState = .playing
        statistics.reset()
        
        // 웨이브 시스템 초기화
        currentWaveNumber = 1
        waveStartTime = 0  // update에서 첫 번째 호출 시 설정됨
        statistics.currentWave = currentWaveNumber
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
    
    // MARK: - Statistics Management
    func addScore(_ points: Int = GameConstants.Balance.scorePerKill) {
        guard isGameActive() else { return }
        statistics.addScore(points)
    }
    
    func updatePlayTime(deltaTime: TimeInterval) {
        guard isGameActive() else { return }
        statistics.updatePlayTime(deltaTime: deltaTime)
    }
    
    func getScore() -> Int {
        return statistics.score
    }
    
    func getZombieKills() -> Int {
        return statistics.zombieKills
    }
    
    func getPlayTime() -> TimeInterval {
        return statistics.playTime
    }
    
    func getCurrentWave() -> Int {
        return statistics.currentWave
    }
    
    func getFormattedPlayTime() -> String {
        let minutes = Int(statistics.playTime) / 60
        let seconds = Int(statistics.playTime) % 60
        return String(format: GameConstants.Text.playTime, minutes, seconds)
    }
    
    // MARK: - Wave Management
    func updateWaveSystem(currentTime: TimeInterval) -> Bool {
        guard isGameActive() else { return false }
        
        // 첫 번째 업데이트에서 웨이브 시작 시간 설정
        if waveStartTime == 0 {
            waveStartTime = currentTime
            return false
        }
        
        // 30초가 지났는지 확인
        let elapsedTime = currentTime - waveStartTime
        if elapsedTime >= GameConstants.Wave.duration {
            // 다음 웨이브로 진행
            currentWaveNumber += 1
            statistics.currentWave = currentWaveNumber
            waveStartTime = currentTime
            
            return true  // 새로운 웨이브 시작됨
        }
        
        return false
    }
    
    func getCurrentWaveNumber() -> Int {
        return currentWaveNumber
    }
    
    func getWaveProgress(currentTime: TimeInterval) -> Float {
        guard waveStartTime > 0 else { return 0 }
        
        let elapsedTime = currentTime - waveStartTime
        return Float(elapsedTime / GameConstants.Wave.duration)
    }
    
    func getZombieSpeedMultiplier() -> Float {
        let multiplier = pow(GameConstants.Wave.speedMultiplier, Float(currentWaveNumber - 1))
        return min(multiplier, GameConstants.Wave.maxSpeedMultiplier)
    }
    
    func getZombieHealthMultiplier() -> Float {
        let multiplier = pow(GameConstants.Wave.healthMultiplier, Float(currentWaveNumber - 1))
        return min(multiplier, GameConstants.Wave.maxHealthMultiplier)
    }
    
    func getZombieCountMultiplier() -> Float {
        return pow(GameConstants.Wave.zombieCountMultiplier, Float(currentWaveNumber - 1))
    }
    
    // MARK: - Debug
    func getCurrentStateDescription() -> String {
        switch currentState {
        case .playing:
            return "Playing - Score: \(statistics.score), Time: \(getFormattedPlayTime())"
        case .gameOver:
            return "Game Over - Final Score: \(statistics.score)"
        case .loading:
            return "Loading"
        }
    }
}
