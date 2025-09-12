import Foundation
import SwiftUI


// MARK: - App Router
@Observable
final class AppRouter {
    // MARK: - Navigation Properties
    var path: [Route] = []

    // MARK: - Computed Properties
    var currentRoute: Route {
        path.last ?? .loading
    }

    var canGoBack: Bool {
        path.count > 1
    }

    // MARK: - Initialization
    init() {
        // 초기 route 설정
        navigate(to: .loading)
    }

    
    // MARK: - Navigation Methods
    func navigate(to route: Route) {
        guard currentRoute != route else { return }

        print("🔄 Navigation: \(currentRoute) → \(route)")

        // 오디오 처리
        handleAudioTransition(to: route)

        // path에 추가 (currentRoute는 자동으로 업데이트됨)
        path.append(route)
    }

    func goBack() {
        guard canGoBack else { return }

        let current = currentRoute
        print("🔄 Navigation: \(current) ← BACKWARD")

        // path에서 제거 (currentRoute는 자동으로 업데이트됨)
        path.removeLast()
    }

    func quitToMainMenu() {
        print("🔄 Navigation: \(currentRoute) → mainMenu")

        // 오디오 처리
        handleAudioTransition(to: .mainMenu)

        // path 재설정 (currentRoute는 자동으로 업데이트됨)
        path = [.mainMenu]
    }


    // MARK: - 역호환성 유지
    func showGameOver(playTime: Int, score: Int, success: Bool = false) {
        navigate(to: .gameOver(playTime: playTime, score: score, success: success))
    }

    private func handleAudioTransition(to route: Route) {
        switch route {
        case .mainMenu, .settings, .leaderboard:
            AudioManager.shared.playMainMenuMusic()
        case .game:
            AudioManager.shared.playGameMusic()
        case .gameOver, .loading:
            AudioManager.shared.playMainMenuMusic()
            break
        }
    }
}


