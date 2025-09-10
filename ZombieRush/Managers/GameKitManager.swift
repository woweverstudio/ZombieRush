import Foundation
import GameKit
import SwiftUI
import UIKit

@Observable
class GameKitManager: NSObject {

    // MARK: - Observable Properties
    var isAuthenticated = false
    var isLoading = false
    var playerDisplayName = "Guest"
    var playerPhoto: UIImage? = nil
    var playerScore: Int64 = 0
    var playerRank: Int? = nil

    // 리더보드 1~3등 데이터
    var topThreeEntries: [GKLeaderboard.Entry] = []

    // 리더보드 1~100등 배열 (데이터 로드 안함)
    var top100Entries: [GKLeaderboard.Entry] = []

    // MARK: - Private Properties
    private var localPlayer: GKLocalPlayer?

    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
    }

    // MARK: - 앱 시작 시 데이터 로드 (로딩화면용)

    /// 앱 시작 시 모든 데이터 로드 (2초 동안)
    func loadInitialData(completion: (() -> Void)? = nil) {
        isLoading = true

        // 1. Game Center 인증
        if !isAuthenticated {
            authenticateWithCallback { [weak self] success in
                guard let self = self else { return }

                // 2. 인증 성공 시 데이터 로드
                if success {
                    Task {
                        await self.loadPlayerData()
                        await self.loadTopThreeLeaderboard()

                        // 로딩 완료
                        self.isLoading = false
                        completion?()
                    }
                } else {
                    // 인증 실패 시에도 로딩 완료
                    self.isLoading = false
                    completion?()
                }
            }
        } else {
            // 이미 인증된 경우 바로 데이터 로드
            Task {
                await loadPlayerData()
                await loadTopThreeLeaderboard()

                // 로딩 완료
                isLoading = false
                completion?()
            }
        }
    }

    // MARK: - 인증


    private func authenticateWithCallback(completion: @escaping (Bool) -> Void) {
        guard let localPlayer = localPlayer else {
            print("🎮 GameKit: Local player unavailable")
            completion(false)
            return
        }

        // 시나리오 1: 이미 인증된 경우
        if localPlayer.isAuthenticated {
            print("🎮 GameKit: Already authenticated")
            completion(true)
            return
        }

        // 시나리오 2-3: 인증 필요
        var isCompleted = false
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self, !isCompleted else { return }
            isCompleted = true

            // 뷰 컨트롤러 표시
            if let viewController = viewController {
                print("🎮 GameKit: 인증 뷰 컨트롤러 표시")
                DispatchQueue.main.async {
                    self.presentViewController?(viewController)
                }
                return // 결과 기다림
            }

            // 인증 결과 처리
            if let error = error {
                print("🎮 GameKit: ❌ Authentication error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.dismissViewController?()
                }
                completion(false)
            } else if localPlayer.isAuthenticated {
                print("🎮 GameKit: ✅ Authentication successful")
                DispatchQueue.main.async {
                    self.dismissViewController?()
                    self.onAuthenticationCompleted?()
                }
                completion(true)
            } else {
                print("🎮 GameKit: ❌ Authentication failed")
                DispatchQueue.main.async {
                    self.dismissViewController?()
                }
                completion(false)
            }
        }
    }


    // MARK: - 플레이어 데이터 로드

    private func loadPlayerData() async {
        guard isAuthenticated, let localPlayer = localPlayer else { return }

        // 플레이어 이름
        playerDisplayName = localPlayer.displayName

        // 프로필 사진 로드
        do {
            let image = try await localPlayer.loadPhoto(for: .small)
            await MainActor.run { [weak self] in
                self?.playerPhoto = image
            }
        } catch {
            print("🎮 GameKit: Failed to load player photo: \(error)")
        }

        // 플레이어 최고 점수 및 랭크 로드
        await loadPlayerScoreAndRank()
    }

    private func loadPlayerScoreAndRank() async {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])

            guard let leaderboard = leaderboards.first else { return }

            // 플레이어의 최고 점수 및 랭크 로드
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

    // MARK: - 리더보드 데이터 로드

    private func loadTopThreeLeaderboard() async {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])

            guard let leaderboard = leaderboards.first else { return }

            // 상위 3명 데이터 로드
            let entries = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 3)
            )

            await MainActor.run { [weak self] in
                self?.topThreeEntries = entries.1
            }

            // 상위 3명의 프로필 이미지 로드
            await loadTopThreeImages()

        } catch {
            print("🎮 GameKit: Failed to load top 3 leaderboard: \(error)")
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

    // MARK: - 점수 제출

    func submitScore(_ score: Int64) async throws {
        guard isAuthenticated else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])

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

    // MARK: - 프로필 이미지 캐시 (Top 3용)
    var profileImages: [String: UIImage] = [:]

    // MARK: - 뷰 컨트롤러 처리 클로저
    var presentViewController: ((UIViewController) -> Void)?
    var dismissViewController: (() -> Void)?
    var onAuthenticationCompleted: (() -> Void)?

    // MARK: - 테스트용 데이터 확인 함수

    /// 로드된 데이터를 콘솔에 출력 (테스트용)
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
        for (playerID, _) in profileImages {
            print("🎮   - \(playerID): ✅ 이미지 로드됨")
        }

        print("🎮 리더보드 1~100 배열 크기: \(top100Entries.count)")

        print("🎮 === 데이터 로드 완료 ===")
    }
}

