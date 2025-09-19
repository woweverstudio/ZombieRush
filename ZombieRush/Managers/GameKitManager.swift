import Foundation
import GameKit
import SwiftUI
import UIKit

@Observable
class GameKitManager: NSObject {

    // MARK: - Authentication State
    var isAuthenticated = false
    var isLoading = false

    // MARK: - Player Data
    var playerID: String = ""
    var playerDisplayName = "Guest"
    var playerPhoto: UIImage? = nil

    // MARK: - UI Callbacks
    var presentViewController: ((UIViewController) -> Void)?
    var dismissViewController: (() -> Void)?

    // MARK: - Private Properties
    private var localPlayer: GKLocalPlayer?

    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
    }

    // MARK: - Initial Data Loading

    /// 플레이어 데이터를 초기화합니다.
    func resetData() {
        playerID = ""
        playerDisplayName = "Guest"
        playerPhoto = nil
    }

    /// 앱 시작 시 플레이어 데이터를 로드합니다 (콜백 방식).
    func loadInitialData(completion: (() -> Void)? = nil) {
        isLoading = true

        if isAuthenticated {
            // 이미 인증된 경우 바로 데이터 로드
            loadAuthenticatedData(completion: completion)
        } else {
            // 인증이 필요한 경우
            authenticateWithCallback { [weak self] success in
                guard let self = self else { return }

                if success {
                    self.loadAuthenticatedData(completion: completion)
                } else {
                    // 인증 실패 시 로딩 완료
                    self.isLoading = false
                    completion?()
                }
            }
        }
    }

    /// Async 버전: 앱 시작 시 플레이어 데이터를 로드합니다.
    func loadInitialDataAsync() async {
        isLoading = true

        if isAuthenticated {
            // 이미 인증된 경우 바로 데이터 로드
            await loadAuthenticatedDataAsync()
        } else {
            // 인증이 필요한 경우
            let success = await authenticateAsync()
            if success {
                await loadAuthenticatedDataAsync()
            } else {
                // 인증 실패 시 로딩 완료
                isLoading = false
            }
        }
    }

    /// 인증된 플레이어 데이터 로드 (콜백 방식)
    private func loadAuthenticatedData(completion: (() -> Void)?) {
        Task {
            await loadPlayerData()
            await MainActor.run {
                self.isLoading = false
                completion?()
            }
        }
    }

    // MARK: - Authentication

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

    // MARK: - Player Data Loading

    /// 플레이어 기본 정보 로드
    private func loadPlayerData() async {
        guard isAuthenticated, let localPlayer = localPlayer else { return }

        await MainActor.run { [weak self] in
            self?.playerID = localPlayer.gamePlayerID
            self?.playerDisplayName = localPlayer.displayName
        }

        // 프로필 사진 로드
        await loadPlayerPhoto()
    }

    /// 플레이어 프로필 사진 로드
    private func loadPlayerPhoto() async {
        guard let localPlayer = localPlayer else { return }

        do {
            let image = try await localPlayer.loadPhoto(for: .small)
            await MainActor.run { [weak self] in
                self?.playerPhoto = image
            }
            print("🎮 GameKit: Player photo loaded successfully")
        } catch {
            print("🎮 GameKit: Failed to load player photo: \(error.localizedDescription)")
            // 사진 로드 실패해도 다른 기능들은 정상 작동하도록 함
        }
    }

    /// Async 버전: Game Center 인증
    private func authenticateAsync() async -> Bool {
        return await withCheckedContinuation { continuation in
            authenticateWithCallback { success in
                continuation.resume(returning: success)
            }
        }
    }

    /// Async 버전: 인증된 플레이어 데이터 로드
    private func loadAuthenticatedDataAsync() async {
        await loadPlayerData()
        await MainActor.run { [weak self] in
            self?.isLoading = false
        }
    }
}
