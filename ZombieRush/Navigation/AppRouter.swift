import Foundation
import SwiftUI

// MARK: - Navigation Direction
enum NavigationDirection {
    case forward
    case backward
}

// MARK: - App Router (Single Source of Truth)
@Observable
final class AppRouter {
    
    // MARK: - Observable Properties (직접 노출로 변경 감지 보장)
    private(set) var currentRoute: Route = .loading
    private(set) var previousRoute: Route?
    private(set) var gameData: GameData?
    private(set) var navigationDirection: NavigationDirection = .forward

    // MARK: - Initialization
    init() {
        // 앱 시작 시 로딩 화면으로 시작 (초기 라우트는 .loading)
    }

    
    // MARK: - Navigation Methods
    func navigate(to route: Route, with data: GameData? = nil, animated: Bool = true) {
        guard currentRoute != route else { return }
        
        navigationDirection = .forward
        print("🔄 Navigation: \(currentRoute) → \(route) (FORWARD)")
        
        // 오디오 처리
        handleAudioTransition(to: route)
        
        // 직접 프로퍼티 업데이트 (@Observable이 감지)
        previousRoute = currentRoute
        currentRoute = route
        gameData = data
    }
    
    func goBack(animated: Bool = true) {
        guard let previous = previousRoute else { return }
        
        navigationDirection = .backward
        print("🔄 Navigation: \(currentRoute) ← \(previous) (BACKWARD)")
        
        // 직접 프로퍼티 업데이트 (@Observable이 감지)
        currentRoute = previous
        previousRoute = nil
        gameData = nil
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
        print("🔄 Navigation: \(currentRoute) → mainMenu (BACKWARD)")
        
        // 오디오 처리
        handleAudioTransition(to: .mainMenu)
        
        // 직접 프로퍼티 업데이트 (@Observable이 감지)
        previousRoute = currentRoute
        currentRoute = .mainMenu
        gameData = nil
    }
    
    func completeLoading(animated: Bool = true) {
        // 더 이상 사용되지 않음 - 바로 메인메뉴로 시작
        // 호환성을 위해 메서드는 유지하되 아무것도 하지 않음
    }
    
    private func handleAudioTransition(to route: Route) {
        switch route {
        case .mainMenu, .settings, .leaderboard:
            AudioManager.shared.playMainMenuMusic()
        case .game:
            AudioManager.shared.playGameMusic()
        case .gameOver, .loading:
            // 게임오버 시에는 음악 변경하지 않음 (게임 음악 유지)
            break
        }
    }
    

    
    // MARK: - Computed Properties
    var currentGameData: GameData? {
        gameData
    }
    
    var canGoBack: Bool {
        previousRoute != nil
    }
}


