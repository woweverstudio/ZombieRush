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

        print("🔄 GameKit 데이터 초기화 완료")
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
        print("🔄 데이터 새로고침 시작 - 캐시 초기화")

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
            print("🎮 GameKit: No local player")
            completion(false)
            return
        }

        // 이미 인증된 경우
        if localPlayer.isAuthenticated {
            print("🎮 GameKit: Already logged in")
            isAuthenticated = true
            completion(true)
            return
        }

        print("🎮 GameKit: Setting up Game Center login")

        // Game Center 인증 핸들러 설정
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }

            if let viewController = viewController {
                // 로그인 화면 표시
                print("🎮 GameKit: Showing Game Center login")
                DispatchQueue.main.async {
                    self.presentViewController?(viewController)
                }
            } else if let error = error {
                // 로그인 실패
                print("🎮 GameKit: Login failed")
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
                timeScope: .allTime,
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
                timeScope: .allTime,
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
    func loadTop100Leaderboard(completion: (() -> Void)? = nil) async {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(
                IDs: [TextConstants.GameCenter.currentLeaderboardID]
            )

            guard let leaderboard = leaderboards.first else {
                print("🎮 GameKit: Leaderboard not found")
                completion?()
                return
            }

            let entries = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 100)
            )

            await MainActor.run { [weak self] in
                self?.top100Entries = entries.1
                print("🎮 GameKit: Loaded \(entries.1.count) entries for top 100")
            }

            // 상위 100 플레이어들의 프로필 이미지 로드
            await loadTop100Images()

            completion?()

        } catch {
            print("🎮 GameKit: Failed to load top 100 leaderboard: \(error)")
            completion?()
        }
    }

    private func loadTop100Images() async {
        for entry in top100Entries {
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
            player: GKLocalPlayer.local
        )

        print("🎮 GameKit: Score submitted successfully: \(score)")
    }

    // MARK: - Debug Functions

    /// 로드된 데이터를 콘솔에 출력 (디버깅용)
    func printDataStatus() {
        print("🎮 === GameKitManager 데이터 상태 ===")
        print("🎮 인증 상태: \(isAuthenticated ? "✅ 인증됨" : "❌ 미인증 (게스트 모드)")")
        print("🎮 플레이어 이름: \(playerDisplayName)")
        print("🎮 플레이어 점수: \(playerScore)")
        print("🎮 플레이어 랭크: \(playerRank != nil ? "#\(playerRank!)" : "없음")")
        print("🎮 프로필 이미지: \(playerPhoto != nil ? "✅ 로드됨" : "❌ 없음")")

        print("🎮 === 리더보드 데이터 (Top 3) ===")
        if topThreeEntries.isEmpty {
            print("🎮 리더보드 데이터: ❌ 없음")
        } else {
            for (index, entry) in topThreeEntries.enumerated() {
                let rank = index + 1
                let name = entry.player.displayName
                let score = entry.score
                print("🎮 #\(rank): \(name) - \(score)점")
            }
        }

        print("🎮 프로필 이미지 캐시: \(profileImages.count)개")
        print("🎮 리더보드 1~100 배열 크기: \(top100Entries.count)")
        print("🎮 === 데이터 로드 완료 ===")
    }
}
