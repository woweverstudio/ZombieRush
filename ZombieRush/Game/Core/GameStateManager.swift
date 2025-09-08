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

    private static let maxValue: Int = 65535  // 16비트 최대값
    private static let timeShift: Int = 16    // 시간 비트 시프트
    private static let mask: Int64 = 0xFFFF   // 16비트 마스크

    var encoded: Int64 {
        let safeTime = min(timeInSeconds, Self.maxValue)
        let safeKills = min(zombieKills, Self.maxValue)
        return (Int64(safeTime) << Self.timeShift) | Int64(safeKills)
    }

    init(encoded: Int64) {
        self.timeInSeconds = Int((encoded >> Self.timeShift) & Self.mask)
        self.zombieKills = Int(encoded & Self.mask)
    }

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
    
    var totalScore: Int {
        return Int(encoded)  // 32비트 점수 (시간 16비트 + 킬수 16비트)
    }
}

// MARK: - Game Statistics
struct GameStatistics {
    var score: Int = 0
    var zombieKills: Int = 0
    var playTime: TimeInterval = 0
    var currentWave: Int = 1  // 웨이브는 1부터 시작
    
    mutating func reset() {
        score = 0
        zombieKills = 0
        playTime = 0
        currentWave = 1  // 웨이브는 1부터 시작
    }
    
    mutating func updatePlayTime(deltaTime: TimeInterval) {
        playTime += deltaTime
    }
    
    mutating func addScore(_ points: Int = GameBalance.Score.perKill) {
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
    private(set) var isAppActive: Bool = true  // 앱 활성 상태 추적
    
    // MARK: - Dependencies
    private var gameKitManager: GameKitManager?
    
    // MARK: - Wave System
    private var currentWaveNumber: Int = 1
    private var previousWaveNumber: Int = 1  // 이전 프레임의 웨이브 번호
    
    // MARK: - Personal Records
    private static let personalRecordsKey = "PersonalRecords"
    private static let maxRecordsCount = 10
    
    // MARK: - State Management
    private init() {}
    
    // MARK: - Dependency Injection
    func setGameKitManager(_ gameKitManager: GameKitManager) {
        self.gameKitManager = gameKitManager
    }
    
    // MARK: - Public Methods
    func startNewGame() {
        currentState = .playing
        statistics.reset()
        
        // 웨이브 시스템 초기화
        currentWaveNumber = 1
        previousWaveNumber = 1
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
    
    // 앱 활성 상태 확인 메소드
    func isAppCurrentlyActive() -> Bool {
        return isAppActive
    }
    
    // MARK: - Statistics Management
    func addScore(_ points: Int = GameBalance.Score.perKill) {
        guard isGameActive() else { return }
        statistics.addScore(points)
    }
    
    func updatePlayTime(deltaTime: TimeInterval) {
        // 앱이 비활성 상태이거나 게임이 일시정지된 경우 시간 업데이트 중지
        guard isGameActive() && isAppActive else { return }
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
        return String(format: TextConstants.GameOver.playTimeFormat, minutes, seconds)
    }
    
    // MARK: - Wave Management
    func updateWaveSystem(currentTime: TimeInterval) -> Bool {
        guard isGameActive() else { return false }
        
        // playTime을 기준으로 현재 웨이브 계산
        let waveDuration = GameBalance.Wave.duration
        let calculatedWave = Int(statistics.playTime / waveDuration) + 1
        
        // 계산된 웨이브가 현재 웨이브보다 크면 웨이브 상승
        if calculatedWave > currentWaveNumber {
            previousWaveNumber = currentWaveNumber
            currentWaveNumber = calculatedWave
            statistics.currentWave = currentWaveNumber
            
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
        let playTimeInCurrentWave = statistics.playTime.truncatingRemainder(dividingBy: waveDuration)
        return Float(playTimeInCurrentWave / waveDuration)
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
        
        records.append(newRecord)
        
        records.sort { $0.totalScore > $1.totalScore }
        
        if records.count > Self.maxRecordsCount {
            records = Array(records.prefix(Self.maxRecordsCount))
        }
        
        let encodedRecords = records.map { $0.encoded }
        UserDefaults.standard.set(encodedRecords, forKey: Self.personalRecordsKey)
    }
    
    /// 개인 랭크 기록들을 가져옴
    func getPersonalRecords() -> [PersonalRecord] {
        guard let encodedRecords = UserDefaults.standard.array(forKey: Self.personalRecordsKey) as? [Int64] else {
            return []
        }
        
        return encodedRecords.map { PersonalRecord(encoded: $0) }
    }
    
    /// 현재 기록이 새로운 기록인지 확인 (저장 전에 체크)
    func isNewRecord() -> Bool {
        let records = getPersonalRecords()
        
        // 기록이 없으면 새로운 기록
        guard !records.isEmpty else { return true }
        
        let currentRecord = PersonalRecord(
            timeInSeconds: Int(statistics.playTime),
            zombieKills: statistics.zombieKills
        )
        let currentScore = Int(currentRecord.encoded)
        
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
    
    private func submitScoreToGameCenter() {
        guard let gameKitManager = gameKitManager else { return }
        
        let record = PersonalRecord(
            timeInSeconds: Int(statistics.playTime),
            zombieKills: statistics.zombieKills
        )
        let encodedScore = record.encoded
        
        Task {
            do {
                try await gameKitManager.submitScore(encodedScore)
            } catch {
                // Game Center 점수 제출 실패 (게임 진행에는 영향 없음)
            }
        }
    }
    
    // MARK: - App State Management
    func setAppActive(_ active: Bool) {
        isAppActive = active
    }
}
