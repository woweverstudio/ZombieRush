import Foundation
import GameKit
import SwiftUI
import UIKit

// MARK: - Game Center Notifications
extension Notification.Name {
    static let gameCenterAuthStateChanged = Notification.Name("gameCenterAuthStateChanged")
    static let gameCenterLoginSuccess = Notification.Name("gameCenterLoginSuccess")
}

@Observable
final class GameKitManager: NSObject {

    // MARK: - Authentication State
    var isAuthenticated = false

    // MARK: - Authentication Tracking
    private var hasAttemptedAuthentication = false
    private var authenticationObserver: NSObjectProtocol?


    // MARK: - Player Data Structure
    /// Game Center 플레이어 정보 구조체
    struct PlayerInfo {
        /// Game Center gamePlayerID (계정별로 고유한 ID)
        let playerID: String
        let nickname: String
    }

    // MARK: - Properties
    private var localPlayer: GKLocalPlayer?

    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
        // 초기에는 모니터링 시작하지 않음 (인증 실패 시 시작)
    }

    deinit {
        // Notification observer 해제
        if let observer = authenticationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Authentication Monitoring
    private func startAuthenticationMonitoring() {
        // 이미 모니터링 중이면 중복 시작 방지
        guard authenticationObserver == nil else { return }

        // Game Center 인증 상태 변경 실시간 모니터링 시작
        authenticationObserver = NotificationCenter.default.addObserver(
            forName: .GKPlayerAuthenticationDidChangeNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAuthenticationStateChange()
        }
    }

    private func handleAuthenticationStateChange() {
        let wasAuthenticated = isAuthenticated
        let isNowAuthenticated = localPlayer?.isAuthenticated ?? false

        // 인증 상태 업데이트
        isAuthenticated = isNowAuthenticated

        // 로그인 성공 시 특별 알림
        if !wasAuthenticated && isNowAuthenticated && hasAttemptedAuthentication {
            NotificationCenter.default.post(
                name: .gameCenterLoginSuccess,
                object: nil
            )
        }
    }

    // MARK: - Player Info Loading

    /// Async 버전: 플레이어 정보를 가져옵니다.
    func getPlayerInfoAsync() async -> PlayerInfo? {
        if isAuthenticated {
            // 이미 인증된 경우 바로 데이터 로드
            return await loadPlayerInfoAsync()
        } else {
            // 인증이 필요한 경우
            let success = await authenticateAsync()
            if success {
                return await loadPlayerInfoAsync()
            } else {
                // ✅ 인증 실패 시 모니터링 시작 (이후 로그인 감지용)
                startAuthenticationMonitoring()
                return nil
            }
        }
    }
    
    /// 플레이어 정보를 로드하여 반환
    private func loadPlayerInfoAsync() async -> PlayerInfo? {
        guard isAuthenticated, let localPlayer = localPlayer else {
            return nil
        }

        // 플레이어 기본 정보 가져오기
        // gamePlayerID는 Game Center 계정별로 고유한 ID (기기 변경 시에도 동일)
        let playerID = localPlayer.gamePlayerID
        let nickname = localPlayer.displayName

        return PlayerInfo(playerID: playerID, nickname: nickname)
    }

    // MARK: - Authentication
    
    /// Async 버전: Game Center 인증
    private func authenticateAsync() async -> Bool {
        return await withCheckedContinuation { continuation in
            authenticateWithCallback { success in
                continuation.resume(returning: success)
            }
        }
    }

    /// Game Center 인증 (재사용 가능)
    private func authenticateWithCallback(completion: @escaping (Bool) -> Void) {
        guard let localPlayer = localPlayer else {
            completion(false)
            return
        }

        // 인증 시도 기록
        hasAttemptedAuthentication = true

        // 이미 인증된 경우
        if localPlayer.isAuthenticated {
            isAuthenticated = true
            completion(true)
            return
        }

        // 중복 호출 방지 플래그 (메서드별)
        var hasCompleted = false

        // Game Center 인증 핸들러 설정 (재설정 가능)
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self, !hasCompleted else { return }

            if localPlayer.isAuthenticated {
                // 로그인 성공
                print("🎮 GameKit: Login successful")
                hasCompleted = true
                self.isAuthenticated = true
                completion(true)
                
            } else if let error = error {
                // 로그인 실패
                print("🎮 GameKit: Login failed (\(error.localizedDescription))")
                hasCompleted = true
                self.isAuthenticated = false
                completion(false)
            } else {
                // 취소됨
                print("🎮 GameKit: Login cancelled")
                hasCompleted = true
                self.isAuthenticated = false
                completion(false)
            }
        }
    }
}
