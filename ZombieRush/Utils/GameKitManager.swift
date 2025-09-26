import Foundation
import GameKit
import SwiftUI
import UIKit

@Observable
final class GameKitManager: NSObject {

    // MARK: - Authentication State
    var isAuthenticated = false

    // MARK: - Player Data Structure
    /// Game Center 플레이어 정보 구조체
    struct PlayerInfo {
        let playerID: String
        let nickname: String
        
        static let defaultPlayerInfo: PlayerInfo = PlayerInfo(playerID: "guest", nickname: "guest")
    }

    // MARK: - UI Callbacks
    var presentViewController: ((UIViewController) -> Void)?
    var dismissViewController: (() -> Void)?

    // MARK: - Properties
    private var localPlayer: GKLocalPlayer?
    var playerPhoto: UIImage?

    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
    }

    // MARK: - Player Info Loading

    /// Async 버전: 플레이어 정보를 가져옵니다.
    func getPlayerInfoAsync() async -> PlayerInfo {
        if isAuthenticated {
            // 이미 인증된 경우 바로 데이터 로드
            return await loadPlayerInfoAsync()
        } else {
            // 인증이 필요한 경우
            let success = await authenticateAsync()
            if success {
                return await loadPlayerInfoAsync()
            } else {
                // 인증 실패
                return PlayerInfo.defaultPlayerInfo
            }
        }
    }
    
    /// 플레이어 정보를 로드하여 반환
    private func loadPlayerInfoAsync() async -> PlayerInfo {
        guard isAuthenticated, let localPlayer = localPlayer else {
            return PlayerInfo.defaultPlayerInfo
        }

        // 플레이어 기본 정보 가져오기
        let playerID = localPlayer.gamePlayerID
        let nickname = localPlayer.displayName

        // 프로필 사진 로드
        self.playerPhoto = try? await localPlayer.loadPhoto(for: .small)

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

    /// Game Center 인증 (한 번만 completion 호출 보장)
    private func authenticateWithCallback(completion: @escaping (Bool) -> Void) {
        guard let localPlayer = localPlayer else {
            completion(false)
            return
        }

        // 이미 인증된 경우
        if localPlayer.isAuthenticated {
            isAuthenticated = true
            completion(true)
            return
        }

        // 중복 호출 방지 플래그
        var hasCompleted = false

        // Game Center 인증 핸들러 설정
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self, !hasCompleted else { return }

            if let viewController = viewController {
                // 로그인 화면 표시 (여기서는 completion 호출하지 않음)
                DispatchQueue.main.async {
                    self.presentViewController?(viewController)
                }
            } else if let error = error {
                // 로그인 실패
                print("🎮 GameKit: Login failed (\(error.localizedDescription)")
                hasCompleted = true
                self.isAuthenticated = false

                completion(false)
            } else if localPlayer.isAuthenticated {
                // 로그인 성공
                print("🎮 GameKit: Login successful")
                hasCompleted = true
                self.isAuthenticated = true
                completion(true)
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
