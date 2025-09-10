// MARK: - Score Encoding Utilities

/// 게임 점수 인코딩/디코딩 유틸리티 클래스
/// 32비트 점수를 시간(앞 16비트) + 킬수(뒤 16비트)로 인코딩
class ScoreEncodingUtils {

    // MARK: - Constants
    private static let maxValue: Int = 65535  // 16비트 최대값
    private static let timeShift: Int = 16    // 시간 비트 시프트
    private static let mask: Int64 = 0xFFFF   // 16비트 마스크

    // MARK: - Encoding

    /// 시간을 초 단위로, 킬 수를 입력받아 32비트 점수로 인코딩
    /// - Parameters:
    ///   - timeInSeconds: 플레이 시간 (초)
    ///   - zombieKills: 좀비 킬 수
    /// - Returns: 인코딩된 32비트 점수
    static func encodeScore(timeInSeconds: Int, zombieKills: Int) -> Int64 {
        let safeTime = min(timeInSeconds, Self.maxValue)
        let safeKills = min(zombieKills, Self.maxValue)
        return (Int64(safeTime) << Self.timeShift) | Int64(safeKills)
    }

    // MARK: - Decoding

    /// 인코딩된 점수에서 시간(초)을 추출
    /// - Parameter encodedScore: 인코딩된 32비트 점수
    /// - Returns: 시간 (초)
    static func decodeTime(from encodedScore: Int64) -> Int {
        let decodedTime = Int((encodedScore >> Self.timeShift) & Self.mask)
        return max(0, min(decodedTime, Self.maxValue)) // 범위 검증
    }

    /// 인코딩된 점수에서 좀비 킬 수를 추출
    /// - Parameter encodedScore: 인코딩된 32비트 점수
    /// - Returns: 좀비 킬 수
    static func decodeKills(from encodedScore: Int64) -> Int {
        let decodedKills = Int(encodedScore & Self.mask)
        return max(0, min(decodedKills, Self.maxValue)) // 범위 검증
    }

    /// Int 타입의 Game Center 점수를 Int64로 변환하여 디코딩
    /// - Parameter score: Game Center 점수 (Int)
    /// - Returns: (시간(초), 킬 수) 튜플
    static func decodeGameCenterScore(_ score: Int) -> (timeInSeconds: Int, zombieKills: Int) {
        let encodedScore = Int64(score)
        let timeInSeconds = decodeTime(from: encodedScore)
        let zombieKills = decodeKills(from: encodedScore)
        return (timeInSeconds, zombieKills)
    }

    // MARK: - Formatting

    /// 시간을 MM:SS 형식으로 포맷팅
    /// - Parameter timeInSeconds: 시간 (초)
    /// - Returns: "MM:SS" 형식의 문자열
    static func formatTime(_ timeInSeconds: Int) -> String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 시간을 MM:SS 형식으로 포맷팅 (Int64 버전)
    /// - Parameter timeInSeconds: 시간 (초, Int64)
    /// - Returns: "MM:SS" 형식의 문자열
    static func formatTime(_ timeInSeconds: Int64) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 인코딩된 점수에서 시간을 MM:SS 형식으로 포맷팅
    /// - Parameter encodedScore: 인코딩된 32비트 점수
    /// - Returns: "MM:SS" 형식의 문자열
    static func formatTimeFromScore(_ encodedScore: Int64) -> String {
        let timeInSeconds = decodeTime(from: encodedScore)
        return formatTime(timeInSeconds)
    }

    /// 인코딩된 점수에서 킬 수를 추출
    /// - Parameter encodedScore: 인코딩된 32비트 점수
    /// - Returns: 좀비 킬 수
    static func getKillsFromScore(_ encodedScore: Int64) -> Int {
        return decodeKills(from: encodedScore)
    }

    /// 인코딩된 점수에서 킬 수를 추출 (Int 버전 - 호환성)
    /// - Parameter encodedScore: 인코딩된 32비트 점수 (Int)
    /// - Returns: 좀비 킬 수
    static func getKillsFromScore(_ encodedScore: Int) -> Int {
        return getKillsFromScore(Int64(encodedScore))
    }

    // MARK: - Convenience Methods

    /// 시간과 킬 수로부터 포맷된 시간 문자열 생성
    /// - Parameters:
    ///   - timeInSeconds: 시간 (초)
    ///   - zombieKills: 킬 수 (사용되지 않음, 호환성 유지)
    /// - Returns: "MM:SS" 형식의 문자열
    static func formatPlayTime(timeInSeconds: Int, zombieKills: Int = 0) -> String {
        return formatTime(timeInSeconds)
    }

    /// 인코딩된 점수로부터 플레이 시간과 킬 수를 한 번에 추출
    /// - Parameter encodedScore: 인코딩된 32비트 점수
    /// - Returns: (시간(초), 킬 수) 튜플
    static func decodeScore(_ encodedScore: Int64) -> (timeInSeconds: Int, zombieKills: Int) {
        let timeInSeconds = decodeTime(from: encodedScore)
        let zombieKills = decodeKills(from: encodedScore)
        return (timeInSeconds, zombieKills)
    }

    // MARK: - Validation

    /// 주어진 값들이 유효한 범위 내에 있는지 확인
    /// - Parameters:
    ///   - timeInSeconds: 시간 (초)
    ///   - zombieKills: 킬 수
    /// - Returns: 유효하면 true, 아니면 false
    static func isValidScore(timeInSeconds: Int, zombieKills: Int) -> Bool {
        return timeInSeconds >= 0 && timeInSeconds <= Self.maxValue &&
               zombieKills >= 0 && zombieKills <= Self.maxValue
    }
}
