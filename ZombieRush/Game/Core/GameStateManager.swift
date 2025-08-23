import Foundation

// MARK: - Game State Enum
enum GameState {
    case playing
    case gameOver
    case loading
}

// MARK: - Personal Record
struct PersonalRecord {
    let timeInSeconds: Int
    let zombieKills: Int
    
    // 64비트 정수로 인코딩 (상위 32비트: 시간, 하위 32비트: 킬수)
    var encoded: Int64 {
        // 16비트씩 사용하여 안전한 범위 보장
        let safeTime = min(timeInSeconds, 65535)  // 16비트 최대값
        let safeKills = min(zombieKills, 65535)   // 16비트 최대값
        return (Int64(safeTime) << 16) | Int64(safeKills)
    }
    
    // 64비트 정수에서 디코딩
    init(encoded: Int64) {
        self.timeInSeconds = Int((encoded >> 16) & 0xFFFF)  // 상위 16비트
        self.zombieKills = Int(encoded & 0xFFFF)            // 하위 16비트
    }
    
    // 일반 생성자
    init(timeInSeconds: Int, zombieKills: Int) {
        self.timeInSeconds = timeInSeconds
        self.zombieKills = zombieKills
    }
    
    // 시간을 MM:SS 형식으로 반환
    var formattedTime: String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 정렬을 위한 점수 계산 (시간 + 킬수 기반)
    var totalScore: Int {
        return timeInSeconds * 10 + zombieKills  // 시간에 더 높은 가중치
    }
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
    
    // MARK: - Personal Records
    private let personalRecordsKey = "PersonalRecords"
    private let maxRecordsCount = 10
    
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
        return pow(GameConstants.Wave.zombieCountMultiplier, Float(currentWaveNumber))
    }
    
    // MARK: - Personal Records Management
    
    /// 현재 게임 결과를 개인 랭크에 저장
    func saveCurrentGameRecord() {
        let timeInSeconds = Int(statistics.playTime)
        let zombieKills = statistics.zombieKills
        
        let newRecord = PersonalRecord(timeInSeconds: timeInSeconds, zombieKills: zombieKills)
        addPersonalRecord(newRecord)
    }
    
    /// 개인 랭크에 새 기록 추가
    private func addPersonalRecord(_ newRecord: PersonalRecord) {
        var records = getPersonalRecords()
        
        // 새 기록 추가
        records.append(newRecord)
        
        // 점수 기준으로 내림차순 정렬 (높은 점수가 먼저)
        records.sort { $0.totalScore > $1.totalScore }
        
        // 상위 10개만 유지
        if records.count > maxRecordsCount {
            records = Array(records.prefix(maxRecordsCount))
        }
        
        // UserDefaults에 저장 (64비트 정수 배열로)
        let encodedRecords = records.map { $0.encoded }
        UserDefaults.standard.set(encodedRecords, forKey: personalRecordsKey)
    }
    
    /// 개인 랭크 기록들을 가져옴
    func getPersonalRecords() -> [PersonalRecord] {
        guard let encodedRecords = UserDefaults.standard.array(forKey: personalRecordsKey) as? [Int64] else {
            return []
        }
        
        return encodedRecords.map { PersonalRecord(encoded: $0) }
    }
    
    /// 현재 기록이 새로운 기록인지 확인 (저장 전에 체크)
    func isNewRecord() -> Bool {
        let records = getPersonalRecords()
        
        // 기록이 없으면 새로운 기록
        guard !records.isEmpty else { return true }
        
        let currentScore = Int(statistics.playTime) * 10 + statistics.zombieKills
        
        // 현재 점수가 기존 최고 기록보다 높으면 새로운 기록
        return currentScore > records.first?.totalScore ?? 0
    }
    
    /// 게임 종료 시 NEW RECORD 여부를 미리 확인하고 저장
    func saveCurrentGameRecordAndCheckNew() -> Bool {
        let isNew = isNewRecord()  // 저장 전에 미리 체크
        saveCurrentGameRecord()    // 그 다음에 저장
        
        // Game Center에 점수 제출 (비동기)
        submitScoreToGameCenter()
        
        return isNew
    }
    
    /// Game Center에 현재 게임 점수 제출
    private func submitScoreToGameCenter() {
        // PersonalRecord와 동일한 16비트 인코딩 방식 사용
        let timeInSeconds = Int(statistics.playTime)
        let zombieKills = statistics.zombieKills
        
        let safeTime = min(timeInSeconds, 65535)  // 16비트 최대값
        let safeKills = min(zombieKills, 65535)   // 16비트 최대값
        let encodedScore = (Int64(safeTime) << 16) | Int64(safeKills)
        
        Task {
            do {
                try await GameKitManager.shared.submitScore(encodedScore)
                // Game Center에 점수 제출 완료
            } catch {
                // Game Center 점수 제출 실패 (게임 진행에는 영향 없음)
            }
        }
    }
    

}
