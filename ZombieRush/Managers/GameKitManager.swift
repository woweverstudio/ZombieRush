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
    
    // MARK: - Private Properties
    private var authenticationViewController: UIViewController?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        checkGameCenterAvailability()
        authenticateUser()
    }
    
    // MARK: - GameCenter Availability Check
    private func checkGameCenterAvailability() {
        print("GameKit: Checking Game Center availability...")
        
        // iOS 버전 체크 (GameKit은 iOS 4.1+에서 사용 가능)
        if #available(iOS 4.1, *) {
            print("GameKit: iOS version supports Game Center")
        } else {
            print("GameKit: iOS version does not support Game Center")
        }
        
        // Game Center 서비스 가용성 체크
        let localPlayer = GKLocalPlayer.local
        print("GameKit: Local player available: \(localPlayer)")
    }
    
    // MARK: - Authentication
    func authenticateUser() {
        guard !isAuthenticated else { 
            print("GameKit: Already authenticated, skipping")
            return 
        }
        
        print("GameKit: Starting authentication process...")
        
        let localPlayer = GKLocalPlayer.local
        self.localPlayer = localPlayer
        
        print("GameKit: LocalPlayer created, isAuthenticated: \(localPlayer.isAuthenticated)")
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                print("GameKit: Authentication handler called")
                
                if let error = error {
                    print("GameKit Authentication Error: \(error.localizedDescription)")
                    print("GameKit Error Code: \(error.localizedDescription)")
                    
                    // GKErrorDomain Code=15는 일시적인 문제일 수 있으므로 재시도 안내
                    if (error as NSError).code == 15 {
                        print("GameKit: Code 15 error detected - this might resolve automatically")
                        self?.authenticationStatus = "Retrying..."
                        // 3초 후 자동 재시도
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            if !self?.isAuthenticated ?? false {
                                print("GameKit: Auto-retry after Code 15 error")
                                self?.authenticateUser()
                            }
                        }
                    } else {
                        self?.handleAuthenticationFailure()
                    }
                    return
                }
                
                if let viewController = viewController {
                    print("GameKit: Presenting authentication view controller")
                    self?.authenticationViewController = viewController
                    self?.presentAuthenticationViewController(viewController)
                } else if localPlayer.isAuthenticated {
                    print("GameKit: Authentication successful!")
                    self?.handleAuthenticationSuccess()
                } else {
                    print("GameKit: Authentication failed - no viewController and not authenticated")
                    self?.handleAuthenticationFailure()
                }
            }
        }
    }
    
    private func presentAuthenticationViewController(_ viewController: UIViewController) {
        print("GameKit: Attempting to present authentication view controller")
        
        // 현재 최상위 뷰컨트롤러에서 Game Center 로그인 화면 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            print("GameKit: Found root view controller, presenting...")
            rootViewController.present(viewController, animated: true) {
                print("GameKit: Authentication view controller presented")
            }
        } else {
            print("GameKit: Could not find root view controller to present authentication")
        }
    }
    
    private func handleAuthenticationSuccess() {
        guard let localPlayer = localPlayer else { return }
        
        isAuthenticated = true
        playerDisplayName = localPlayer.displayName
        authenticationStatus = "Connected"
        
        print("GameKit Authentication Success: \(playerDisplayName)")
        
        // 프로필 사진 로드
        loadPlayerPhoto()
    }
    
    private func handleAuthenticationFailure() {
        isAuthenticated = false
        playerDisplayName = "Guest"
        playerPhoto = nil
        authenticationStatus = "Guest Mode"
        
        print("GameKit Authentication Failed - Using Guest Mode")
    }
    
    // MARK: - Player Profile
    private func loadPlayerPhoto() {
        guard let localPlayer = localPlayer, isAuthenticated else { return }
        
        localPlayer.loadPhoto(for: .small) { [weak self] image, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load player photo: \(error.localizedDescription)")
                    self?.playerPhoto = nil
                } else {
                    self?.playerPhoto = image
                }
            }
        }
    }
    
    // MARK: - Public Methods
    func retryAuthentication() {
        isAuthenticated = false
        authenticateUser()
    }
    
    func signOut() {
        // GameKit은 직접적인 로그아웃을 지원하지 않음
        // 앱 재시작이나 기기 설정에서 변경해야 함
        isAuthenticated = false
        playerDisplayName = "Guest"
        playerPhoto = nil
    }
    
    // MARK: - Helper Methods
    var isGameCenterAvailable: Bool {
        return GKLocalPlayer.local.isAuthenticated
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
