import Foundation
import GameKit
import SwiftUI
import UIKit

@Observable
class GameKitManager: NSObject {

    // MARK: - Skeleton Entry Structure
    struct SkeletonEntry {
        let rank: Int
        let message: String
        let isSkeleton: Bool = true
    }

    // MARK: - Authentication State
    var isAuthenticated = false
    var isLoading = false

    // MARK: - Player Data
    var playerDisplayName = "Guest"
    var playerPhoto: UIImage? = nil
    var playerScore: Int64 = 0
    var playerRank: Int? = nil

    // MARK: - Leaderboard Data
    var topThreeEntries: [GKLeaderboard.Entry] = []
    var top100Entries: [GKLeaderboard.Entry] = []

    // MARK: - Image Cache
    var profileImages: [String: UIImage] = [:]

    // MARK: - UI Callbacks
    var presentViewController: ((UIViewController) -> Void)?
    var dismissViewController: (() -> Void)?
    var onAuthenticationCompleted: (() -> Void)?

    // MARK: - Private Properties
    private var localPlayer: GKLocalPlayer?

    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
    }

    // MARK: - Initial Data Loading

    /// 캐시된 데이터를 초기화합니다.
    func resetData() {
        // 플레이어 데이터 초기화
        playerDisplayName = "Guest"
        playerPhoto = nil
        playerScore = 0
        playerRank = nil

        // 리더보드 데이터 초기화
        topThreeEntries = []
        top100Entries = []

        // 이미지 캐시 초기화
        profileImages = [:]

    }

    /// 앱 시작 시 모든 데이터를 로드합니다.
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

    /// 데이터를 강제로 새로고침합니다 (캐시 초기화 후 재로드)
    func refreshData(completion: (() -> Void)? = nil) {

        // 데이터 초기화
        resetData()

        // 새로고침 플래그 설정 (인증 상태 유지)
        let wasAuthenticated = isAuthenticated

        if wasAuthenticated {
            // 인증된 상태라면 바로 데이터 재로드
            loadAuthenticatedData(completion: completion)
        } else {
            // 인증되지 않은 상태라면 전체 로드
            loadInitialData(completion: completion)
        }
    }


    private func loadAuthenticatedData(completion: (() -> Void)?) {
        Task {
            await loadPlayerData()
            await loadTopThreeLeaderboard()

            isLoading = false
            completion?()
        }
    }

    // MARK: - Authentication

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


        // Game Center 인증 핸들러 설정
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }

            if let viewController = viewController {
                // 로그인 화면 표시
                DispatchQueue.main.async {
                    self.presentViewController?(viewController)
                }
            } else if let error = error {
                // 로그인 실패
                print("🎮 GameKit: Login failed (\(error.localizedDescription)")
                self.isAuthenticated = false
                completion(false)
            } else if localPlayer.isAuthenticated {
                // 로그인 성공
                print("🎮 GameKit: Login successful")
                self.isAuthenticated = true
                completion(true)
            } else {
                // 취소됨
                print("🎮 GameKit: Login cancelled")
                self.isAuthenticated = false
                completion(false)
            }
        }
    }


    // MARK: - Player Data Loading

    private func loadPlayerData() async {
        guard isAuthenticated, let localPlayer = localPlayer else { return }

        // 플레이어 기본 정보 로드
        playerDisplayName = localPlayer.displayName

        // 프로필 사진 로드
        await loadPlayerPhoto()

        // 점수 및 랭킹 정보 로드
        await loadPlayerScoreAndRank()
    }

    private func loadPlayerPhoto() async {
        guard let localPlayer = localPlayer else { return }

        do {
            let image = try await localPlayer.loadPhoto(for: .small)
            await MainActor.run { [weak self] in
                self?.playerPhoto = image
            }
        } catch {
            print("🎮 GameKit: Failed to load player photo: \(error)")
        }
    }

    private func loadPlayerScoreAndRank() async {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(
                IDs: [TextConstants.GameCenter.currentLeaderboardID]
            )

            guard let leaderboard = leaderboards.first else { return }

            let (localPlayerEntry, _, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .week,
                range: NSRange(location: 1, length: 1)
            )

            await MainActor.run { [weak self] in
                self?.playerScore = Int64(localPlayerEntry?.score ?? 0)
                self?.playerRank = localPlayerEntry?.rank
            }
        } catch {
            print("🎮 GameKit: Failed to load player score/rank: \(error)")
        }
    }

    // MARK: - Leaderboard Data Loading

    private func loadTopThreeLeaderboard() async {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(
                IDs: [TextConstants.GameCenter.currentLeaderboardID]
            )

            guard let leaderboard = leaderboards.first else { return }

            let entries = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .week,
                range: NSRange(location: 1, length: 3)
            )

            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.topThreeEntries = entries.1
            }

            // 상위 플레이어들의 프로필 이미지 로드
            await loadTopThreeImages()

        } catch {
            print("🎮 GameKit: Failed to load top 3 leaderboard: \(error)")
            // 에러 발생 시 빈 배열로 설정
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.topThreeEntries = []
            }
        }
    }

    private func loadTopThreeImages() async {
        for entry in topThreeEntries {
            do {
                let image = try await entry.player.loadPhoto(for: .small)
                await MainActor.run { [weak self] in
                    self?.profileImages[entry.player.gamePlayerID] = image
                }
            } catch {
                print("🎮 GameKit: Failed to load image for \(entry.player.displayName): \(error)")
            }
        }
    }


    /// 상위 100명 리더보드 데이터를 로드합니다.
    func loadTop100Leaderboard(completion: (() -> Void)? = nil) async throws {
        // 인증 상태 확인
        guard isAuthenticated else {
            throw NSError(domain: GKErrorDomain, code: GKError.Code.notAuthenticated.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Not authenticated with Game Center"])
        }

        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(
                IDs: [TextConstants.GameCenter.currentLeaderboardID]
            )

            guard let leaderboard = leaderboards.first else {
                // 커스텀 에러 코드 사용 (GameKit에는 leaderboardNotFound가 없음)
                throw NSError(domain: "GameKit", code: 1001,
                             userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"])
            }

            let entries = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .week,
                range: NSRange(location: 1, length: 100)
            )

            await MainActor.run { [weak self] in
                self?.top100Entries = entries.1
            }

            // 상위 100 플레이어들의 프로필 이미지 로드 (에러가 발생해도 리더보드는 성공으로 처리)
            do {
                try await loadTop100Images()
            } catch {
                print("🎮 GameKit: Failed to load some profile images, but leaderboard data is loaded: \(error)")
                // 프로필 이미지 로드 실패는 리더보드 로드 성공에 영향을 주지 않음
            }

            completion?()

        } catch let error as NSError {
            print("🎮 GameKit: Failed to load top 100 leaderboard: \(error)")

            // 이미 GameKit 에러인 경우 그대로 throw
            if error.domain == GKErrorDomain {
                throw error
            }

            // 그 외의 에러는 네트워크 에러로 처리
            throw NSError(domain: GKErrorDomain, code: GKError.Code.communicationsFailure.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Network connection failed"])
        }
    }

    private func loadTop100Images() async throws {
        var loadedCount = 0
        var failedCount = 0

        for entry in top100Entries {
            do {
                let image = try await entry.player.loadPhoto(for: .small)
                await MainActor.run { [weak self] in
                    self?.profileImages[entry.player.gamePlayerID] = image
                }
                loadedCount += 1
            } catch let error as NSError {
                failedCount += 1
                print("🎮 GameKit: Failed to load image for \(entry.player.displayName): \(error)")

                // GameKit 에러인 경우는 계속 진행 (일부 이미지가 로드되지 않아도 괜찮음)
                if error.domain == GKErrorDomain {
                    continue
                }

                // 다른 에러의 경우 마지막에 경고만 출력하고 계속 진행
                continue
            }
        }

        if failedCount > 0 {
        } else if loadedCount > 0 {
        }
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int64) async throws {
        guard isAuthenticated else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let leaderboards = try await GKLeaderboard.loadLeaderboards(
            IDs: [TextConstants.GameCenter.currentLeaderboardID]
        )

        guard let leaderboard = leaderboards.first else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"])
        }

        try await leaderboard.submitScore(
            Int(score),
            context: 0,
            player: localPlayer ?? .local
        )
        
    }

}
