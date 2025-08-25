import GameKit
import SwiftUI
import UIKit

// MARK: - GameKit Manager
class GameKitManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = GameKitManager()
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var playerDisplayName = "Guest"
    @Published var playerPhoto: UIImage?
    @Published var authenticationStatus = "Checking..."
    @Published var globalLeaderboard: [GKLeaderboard.Entry] = []
    @Published var isLoadingLeaderboard = false
    @Published var showingSampleData = false
    @Published var playerRank: Int?
    @Published var profileImages: [String: UIImage] = [:]  // playerID -> UIImage 캐시
    
    // MARK: - Private Properties
    private var authenticationViewController: UIViewController?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        checkGameCenterAvailability()
        
        // 즉시 인증 시작 - GameKit이 알아서 상태를 처리함
        authenticateUser()
    }
    
    // MARK: - GameCenter Availability Check
    private func checkGameCenterAvailability() {
        // 시뮬레이터에서 Game Center 기능 제한됨
    }
    
    // MARK: - Authentication
    func authenticateUser() {
        guard !isAuthenticated else { return }
        
        authenticationStatus = "Authenticating..."
        let localPlayer = GKLocalPlayer.local
        self.localPlayer = localPlayer
        
        // GameKit의 표준 패턴: authenticateHandler 설정
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                // 에러가 있는 경우
                if error != nil {
                    // 인증 실패 시 게스트 모드로 전환
                    self?.handleAuthenticationFailure()
                    return
                }
                
                // 로그인 화면이 필요한 경우
                if let viewController = viewController {
                    self?.authenticationViewController = viewController
                    self?.presentAuthenticationViewController(viewController)
                    return
                }
                
                // 인증 성공인 경우
                if localPlayer.isAuthenticated {
                    self?.handleAuthenticationSuccess()
                } else {
                    // 인증 실패
                    self?.handleAuthenticationFailure()
                }
            }
        }
    }
    
    private func presentAuthenticationViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                return
            }
            
            func findTopViewController(from root: UIViewController?) -> UIViewController? {
                if let presented = root?.presentedViewController {
                    return findTopViewController(from: presented)
                }
                if let nav = root as? UINavigationController {
                    return findTopViewController(from: nav.visibleViewController)
                }
                if let tab = root as? UITabBarController {
                    return findTopViewController(from: tab.selectedViewController)
                }
                return root
            }
            
            guard let topViewController = findTopViewController(from: window.rootViewController) else {
                return
            }
            
            topViewController.present(viewController, animated: true)
        }
    }
    
    private func handleAuthenticationSuccess() {
        guard let localPlayer = localPlayer else { return }
        
        isAuthenticated = true
        playerDisplayName = localPlayer.displayName
        authenticationStatus = "Connected"
        loadPlayerPhoto()
        
        // GKAccessPoint 활성화
        setupAccessPoint()
        
        Task {
            await loadPlayerRank()
        }
    }
    
    private func handleAuthenticationFailure() {
        isAuthenticated = false
        playerDisplayName = "Guest"
        playerPhoto = nil
        authenticationStatus = "Guest Mode"
    }
    
    // MARK: - Player Profile
    private func loadPlayerPhoto() {
        guard let localPlayer = localPlayer, isAuthenticated else { return }
        
        localPlayer.loadPhoto(for: .small) { [weak self] image, error in
            DispatchQueue.main.async {
                self?.playerPhoto = error == nil ? image : nil
            }
        }
    }
    
    // MARK: - Public Methods
    func retryAuthentication() {
        // 이미 인증되어 있으면 재인증 불필요
        if GKLocalPlayer.local.isAuthenticated && isAuthenticated {
            return
        }
        
        // 상태 리셋 후 재인증
        isAuthenticated = false
        GKLocalPlayer.local.authenticateHandler = nil
        authenticateUser()
    }
    
    // MARK: - GKAccessPoint Setup
    private func setupAccessPoint() {
        DispatchQueue.main.async {
            let accessPoint = GKAccessPoint.shared
            accessPoint.location = .topTrailing
            accessPoint.showHighlights = false  // 하이라이트 비활성화 (깔끔한 UI)
            accessPoint.isActive = false  // 기본적으로 비활성화 (리더보드 화면에서만 활성화)
            
            // Access Point 기본 비활성화 설정 완료
        }
    }
    
    
    // MARK: - Helper Methods
    var isGameCenterAvailable: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var playerID: String {
        return localPlayer?.gamePlayerID ?? "guest"
    }
    
    // MARK: - Leaderboard Methods
    
    /// 점수를 Game Center 리더보드에 제출 (현재 맵)
    func submitScore(_ score: Int64) async throws {
        try await submitScore(score, to: TextConstants.GameCenter.LeaderboardIDs.basic)
    }
    
    /// 특정 맵의 리더보드에 점수 제출 (향후 확장용)
    func submitScore(_ score: Int64, to leaderboardID: String) async throws {
        guard isAuthenticated else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // 점수 제출 시작
        
        // 리더보드 로드 후 점수 제출
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
        
        guard let leaderboard = leaderboards.first else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"])
        }
        
        // 점수 제출
        try await leaderboard.submitScore(
            Int(score),
            context: 0,
            player: GKLocalPlayer.local
        )
        
        // 점수 제출 성공
    }
    
    /// 글로벌 리더보드 데이터 로드 (인증 안된 경우 샘플 데이터 표시)
    func loadGlobalLeaderboard() async throws {
        guard isAuthenticated else {
            // 비로그인 상태 - 샘플 데이터 표시
            await MainActor.run { [weak self] in
                self?.showingSampleData = true
                self?.globalLeaderboard = []
            }
            return
        }
        
        await MainActor.run { [weak self] in
            self?.isLoadingLeaderboard = true
        }
        
        // 글로벌 리더보드 로드 시작
        
        defer {
            Task { @MainActor [weak self] in
                self?.isLoadingLeaderboard = false
            }
        }
        
        // 리더보드 로드
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])
        
        guard let leaderboard = leaderboards.first else {
            throw NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "No leaderboard found"])
        }
        
        // 현재 로드된 데이터 수 확인
        let currentCount = await MainActor.run { [weak self] in
            return self?.globalLeaderboard.count ?? 0
        }
        
        // 점진적 로딩: 처음 20명, 그 다음 30명씩 최대 100명까지
        let batchSize = currentCount == 0 ? 20 : 30
        let loadCount = min(batchSize, 100 - currentCount)
        
        // 상위 데이터 로드
        let (_, entries, _) = try await leaderboard.loadEntries(
            for: .global,
            timeScope: .allTime,
            range: NSRange(location: 1, length: loadCount)
        )
        
        await MainActor.run { [weak self] in
            self?.showingSampleData = false
            self?.globalLeaderboard = entries
        }
        
        // 프로필 이미지 비동기 로드 (백그라운드에서)
        Task {
            await loadProfileImages(for: entries)
        }
    }
    
    /// 더 많은 리더보드 데이터 로드
    func loadMoreLeaderboard() async {
        guard isAuthenticated else { return }
        
        let currentCount = await MainActor.run { [weak self] in
            return self?.globalLeaderboard.count ?? 0
        }
        
        // 이미 100명을 로드했으면 더 이상 로드하지 않음
        guard currentCount < 100 else {
            return // 최대 100개 엔트리 로드 완료
        }
        
        do {
            // 리더보드 로드
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])
            
            guard let leaderboard = leaderboards.first else {
                return // 리더보드를 찾을 수 없음
            }
            
            // 다음 배치 로드 (30명씩)
            let batchSize = 30
            let startIndex = currentCount + 1
            let loadCount = min(batchSize, 100 - currentCount)
            
            let (_, entries, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: startIndex, length: loadCount)
            )
            
            await MainActor.run { [weak self] in
                self?.globalLeaderboard.append(contentsOf: entries)
                // 추가 엔트리 로드 완료
            }
            
            // 프로필 이미지 비동기 로드
            Task {
                await loadProfileImages(for: entries)
            }
            
        } catch {
            // 추가 리더보드 로드 실패 (무시)
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
                // 프로필 이미지 로드 (백그라운드에서)
                let image = try await entry.player.loadPhoto(for: .small)
                
                // 메인 스레드에서 캐시 업데이트
                await MainActor.run { [weak self] in
                    self?.profileImages[playerID] = image
                }
            } catch {
                // 이미지 로드 실패 - 기본 아이콘 사용
            }
        }
    }
    
    /// 현재 플레이어의 리더보드 순위 조회
    func loadPlayerRank() async {
        guard isAuthenticated else {
            await MainActor.run { [weak self] in
                self?.playerRank = nil
            }
            return
        }
        
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [TextConstants.GameCenter.currentLeaderboardID])
            
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
            // 플레이어 랭크 로드 실패
            await MainActor.run { [weak self] in
                self?.playerRank = nil
            }
        }
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
