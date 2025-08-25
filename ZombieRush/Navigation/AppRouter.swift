import Foundation
import SwiftUI
import Combine

// MARK: - Navigation Direction
enum NavigationDirection {
    case forward
    case backward
}

// MARK: - App Router (Single Source of Truth)
class AppRouter: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppRouter()
    
    // MARK: - Published Properties
    @Published private(set) var navigationState = NavigationState()
    @Published var isTransitioning = false
    @Published private(set) var navigationDirection: NavigationDirection = .forward
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupNavigationObserver()
        // 앱 시작 시 메인 화면 음악 재생
        DispatchQueue.main.async {
            self.handleAudioTransition(to: .mainMenu)
        }
    }
    
    // MARK: - Navigation Methods
    func navigate(to route: Route, with data: GameData? = nil, animated: Bool = true) {
        guard navigationState.currentRoute != route else { return }
        
        navigationDirection = .forward
        
        if animated {
            withAnimation(.easeInOut(duration: UIConstants.Animation.transitionDuration)) {
                performNavigation(to: route, with: data)
            }
        } else {
            performNavigation(to: route, with: data)
        }
    }
    
    func goBack(animated: Bool = true) {
        guard navigationState.previousRoute != nil else { return }
        
        navigationDirection = .backward
        
        if animated {
            withAnimation(.easeInOut(duration: UIConstants.Animation.transitionDuration)) {
                navigationState.goBack()
            }
        } else {
            navigationState.goBack()
        }
    }
    
    func restart(animated: Bool = true) {
        let restartData = GameData(isRestart: true)
        navigate(to: .game, with: restartData, animated: animated)
    }
    
    func showGameOver(playTime: TimeInterval, score: Int, wave: Int, isNewRecord: Bool = false, animated: Bool = true) {
        let gameOverData = GameData(playTime: playTime, score: score, wave: wave, isNewRecord: isNewRecord)
        navigate(to: .gameOver, with: gameOverData, animated: animated)
    }
    
    func quitToMainMenu(animated: Bool = true) {
        // 게임에서 메인메뉴로 나가는 것은 "뒤로 가기" 개념
        navigationDirection = .backward
        
        if animated {
            withAnimation(.easeInOut(duration: UIConstants.Animation.transitionDuration)) {
                performNavigation(to: .mainMenu, with: nil)
            }
        } else {
            performNavigation(to: .mainMenu, with: nil)
        }
    }
    
    // MARK: - Private Methods
    private func performNavigation(to route: Route, with data: GameData?) {
        isTransitioning = true
        
        // 오디오 처리
        handleAudioTransition(to: route)
        
        // 네비게이션 상태 업데이트
        navigationState.navigate(to: route, with: data)
        
        // 전환 완료 후 플래그 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + UIConstants.Animation.transitionDuration) {
            self.isTransitioning = false
        }
    }
    
    private func handleAudioTransition(to route: Route) {
        switch route {
        case .mainMenu, .settings, .leaderboard:
            AudioManager.shared.playMainMenuMusic()
        case .game:
            AudioManager.shared.playGameMusic()
        case .gameOver:
            // 게임오버 시에는 음악 변경하지 않음 (게임 음악 유지)
            break
        }
    }
    
    private func setupNavigationObserver() {
        // 라우트 변경 모니터링
        $navigationState
            .map(\.currentRoute)
            .removeDuplicates()
            .sink { _ in
                // 네비게이션 상태 변경 감지
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    var currentRoute: Route {
        navigationState.currentRoute
    }
    
    var currentGameData: GameData? {
        navigationState.gameData
    }
    
    var canGoBack: Bool {
        navigationState.previousRoute != nil
    }
}


