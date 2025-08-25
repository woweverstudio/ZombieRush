import Foundation
import GameKit
import SwiftUI
import UIKit

@Observable
class GameKitManager: NSObject {
    
    // MARK: - Observable Properties (더 이상 @Published 불필요)
    var isAuthenticated = false
    var authenticationStatus = "Initializing..."
    var playerDisplayName = "Guest"
    var playerPhoto: UIImage? = nil
    var playerRank: Int? = nil
    var playerScore: Int64 = 0
    var leaderboardEntries: [GKLeaderboard.Entry] = []
    var profileImages: [String: UIImage] = [:]
    var isLoadingLeaderboard = false
    var showingSampleData = false
    
    // MARK: - Private Properties  
    private var localPlayer: GKLocalPlayer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        localPlayer = GKLocalPlayer.local
    }
    
    // MARK: - Public Authentication Methods
    
    /// 앱 시작 시 GameKit 인증 시도
    func startAuthentication() {
        print("🎮 GameKit: Starting authentication...")
        
        guard let localPlayer = localPlayer else {
            print("🎮 GameKit: ❌ Local player not available")
            return
        }
        
        // 이미 인증된 경우
        if localPlayer.isAuthenticated {
            print("🎮 GameKit: ✅ Already authenticated")
            Task {
                await handleAuthenticationSuccess()
            }
            return
        }
        
        // 인증 시도
        authenticationStatus = "Authenticating..."
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                self?.handleAuthenticationResult(viewController: viewController, error: error)
            }
        }
    }
    
    // MARK: - Private Authentication Methods
    
    private func handleAuthenticationResult(viewController: UIViewController?, error: Error?) {
        print("🎮 GameKit: Authentication result - VC: \(viewController != nil), Error: \(error?.localizedDescription ?? "none")")
        
        // 에러가 있거나 사용자 액션이 필요한 경우 → 게스트 모드
        if error != nil || viewController != nil {
            print("🎮 GameKit: Authentication requires user action - continuing as guest")
            handleAuthenticationFailure(error: error)
            return
        }
        
        // 인증 성공 확인
        if localPlayer?.isAuthenticated == true {
            print("🎮 GameKit: ✅ Authentication successful")
            Task {
                await handleAuthenticationSuccess()
            }
        } else {
            print("🎮 GameKit: ❌ Authentication failed")
            handleAuthenticationFailure(error: nil)
        }
    }
    
    private func handleAuthenticationSuccess() async {
        guard let localPlayer = localPlayer else {
            handleAuthenticationFailure(error: nil)
            return
        }
        
        print("🎮 GameKit: ✅ Authentication successful: \(localPlayer.displayName)")
        
        // 상태 업데이트
        isAuthenticated = true
        playerDisplayName = localPlayer.displayName
        authenticationStatus = "Connected"
        
        // 백그라운드에서 플레이어 데이터 로드 및 캐시
        await loadUserData()
    }
    
    private func handleAuthenticationFailure(error: Error?) {
        print("🎮 GameKit: ❌ Authentication failed - continuing as guest")
        if let error = error {
            print("🎮 GameKit: Error details: \(error.localizedDescription)")
        }
        
        // 게스트 모드 설정
        isAuthenticated = false
        playerDisplayName = "Guest"
        authenticationStatus = "Guest Mode"
        playerPhoto = nil
        playerRank = nil
        playerScore = 0
    }
    
    // MARK: - User Data Loading
    
    private func loadUserData() async {
        guard isAuthenticated, let _ = localPlayer else { return }
        
        // 프로필 사진 로드
        await loadPlayerPhoto()
        
        // 플레이어 랭크 로드
        await loadPlayerRank()
    }
    
    private func loadPlayerPhoto() async {
        guard let localPlayer = localPlayer, isAuthenticated else { return }
        
        do {
            let image = try await localPlayer.loadPhoto(for: .small)
            await MainActor.run { [weak self] in
                self?.playerPhoto = image
            }
        } catch {
            print("🎮 GameKit: Failed to load player photo: \(error)")
        }
    }
    
    func loadPlayerRank() async {
        guard isAuthenticated else {
            await MainActor.run { [weak self] in
                self?.playerRank = nil
            }
            return
        }
        
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.LeaderboardIDs.basic])
            
            guard let leaderboard = leaderboards.first else {
                await MainActor.run { [weak self] in
                    self?.playerRank = nil
                }
                return
            }
            
            let (localPlayerEntry, _, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 1)
            )
            
            await MainActor.run { [weak self] in
                self?.playerRank = localPlayerEntry?.rank
            }
        } catch {
            print("🎮 GameKit: Failed to load player rank: \(error)")
            await MainActor.run { [weak self] in
                self?.playerRank = nil
            }
        }
    }
    
    /// 리더보드 엔트리들의 플레이어 이미지를 백그라운드에서 로드
    private func loadPlayerImages(for entries: [GKLeaderboard.Entry]) async {
        print("🎮 GameKit: Loading player images for \(entries.count) entries...")
        
        // 동시에 최대 10개씩 로드하여 성능 최적화
        await withTaskGroup(of: Void.self) { group in
            for entry in entries.prefix(50) { // 상위 50명만 이미지 로드
                group.addTask { [weak self] in
                    await self?.loadSinglePlayerImage(for: entry)
                }
            }
        }
        
        print("🎮 GameKit: ✅ Player images loading completed")
    }
    
    /// 개별 플레이어 이미지 로드
    private func loadSinglePlayerImage(for entry: GKLeaderboard.Entry) async {
        let playerID = entry.player.gamePlayerID
        
        // 이미 캐시된 이미지가 있으면 건너뛰기
        if profileImages[playerID] != nil {
            return
        }
        
        do {
            let image = try await entry.player.loadPhoto(for: .small)
            
            await MainActor.run { [weak self] in
                self?.profileImages[playerID] = image
            }
        } catch {
            // 이미지 로드 실패는 무시 (기본 이미지 사용)
            print("🎮 GameKit: Failed to load image for player \(entry.player.displayName): \(error)")
        }
    }
    
    // MARK: - Leaderboard Methods
    
    /// 점수를 Game Center 리더보드에 제출
    func submitScore(_ score: Int64) async throws {
        guard isAuthenticated else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.LeaderboardIDs.basic])
        
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
    
    /// 리더보드 진입 시 top 100 데이터 로드
    func loadTop100Leaderboard() async throws {
        print("🎮 GameKit: Loading top 100 leaderboard...")
        
        await MainActor.run { [weak self] in
            self?.isLoadingLeaderboard = true
        }
        
        defer {
            Task { @MainActor [weak self] in
                self?.isLoadingLeaderboard = false
            }
        }
        
        guard isAuthenticated else {
            print("🎮 GameKit: ❌ Not authenticated - cannot load leaderboard")
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.LeaderboardIDs.basic])
        
        guard let leaderboard = leaderboards.first else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"])
        }
        
        // Top 100 엔트리 로드
        let entries = try await leaderboard.loadEntries(
            for: .global,
            timeScope: .allTime,
            range: NSRange(location: 1, length: 100)
        )
        
        // 플레이어 이미지들을 백그라운드에서 로드
        await loadPlayerImages(for: entries.1)
        
        await MainActor.run { [weak self] in
            self?.leaderboardEntries = entries.1
            print("🎮 GameKit: ✅ Top 100 leaderboard loaded (\(entries.1.count) entries)")
        }
    }
    
    /// 글로벌 리더보드 데이터 로드 (기존 메서드 유지)
    func loadGlobalLeaderboard() async throws {
        await MainActor.run { [weak self] in
            self?.isLoadingLeaderboard = true
        }
        
        defer {
            Task { @MainActor [weak self] in
                self?.isLoadingLeaderboard = false
            }
        }
        
        guard isAuthenticated else {
            // 비로그인 상태 - 샘플 데이터 표시
            await MainActor.run { [weak self] in
                self?.showingSampleData = true
                self?.leaderboardEntries = []
            }
            return
        }
        
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.LeaderboardIDs.basic])
        
        guard let leaderboard = leaderboards.first else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "No leaderboard found"])
        }
        
        let (_, entries, _) = try await leaderboard.loadEntries(
            for: .global,
            timeScope: .allTime,
            range: NSRange(location: 1, length: 50)
        )
        
        await MainActor.run { [weak self] in
            self?.showingSampleData = false
            self?.leaderboardEntries = entries
        }
        
        // 프로필 이미지 비동기 로드
        Task {
            await loadProfileImages(for: entries)
        }
    }
    
    /// 프로필 이미지 비동기 로드
    private func loadProfileImages(for entries: [GKLeaderboard.Entry]) async {
        for entry in entries {
            let playerID = entry.player.gamePlayerID
            
            // 이미 로드된 이미지는 스킵
            let alreadyLoaded = await MainActor.run { [weak self] in
                return self?.profileImages[playerID] != nil
            }
            
            if alreadyLoaded { continue }
            
            do {
                let image = try await entry.player.loadPhoto(for: .small)
                await MainActor.run { [weak self] in
                    self?.profileImages[playerID] = image
                }
            } catch {
                // 이미지 로드 실패 - 무시
            }
        }
    }
    
    // MARK: - Utility Properties
    
    var isGameCenterAvailable: Bool {
        return isAuthenticated
    }
    
    var playerID: String {
        return localPlayer?.gamePlayerID ?? "guest"
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
