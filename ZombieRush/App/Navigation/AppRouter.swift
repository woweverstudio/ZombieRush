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


        // 오디오 처리
        handleAudioTransition(to: route)

        // path에 추가 (currentRoute는 자동으로 업데이트됨)
        path.append(route)
    }

    func goBack() {
        guard canGoBack else { return }


        // path에서 제거 (currentRoute는 자동으로 업데이트됨)
        path.removeLast()
    }

    func quitToMain() {

        // 오디오 처리
        handleAudioTransition(to: .main)

        // path 재설정 (currentRoute는 자동으로 업데이트됨)
        path = [.main]
    }


    // MARK: - 역호환성 유지
    func showGameOver(playTime: Int, score: Int, success: Bool = false) {
        navigate(to: .gameOver(playTime: playTime, score: score, success: success))
    }

    private func handleAudioTransition(to route: Route) {
        switch route {
        case .loading, .story:
            AudioManager.shared.playStoryMusic()
        case .serviceUnavailable:
            // 서비스 이용 불가 화면에서는 배경음악 재생하지 않음
            AudioManager.shared.stopBackgroundMusic()
        case .main, .settings, .leaderboard:
            AudioManager.shared.playMainMenuMusic()
        case .market:
            AudioManager.shared.playMarketMusic()
        case .game:
            AudioManager.shared.playGameMusic()
        case .gameOver:
            AudioManager.shared.playMainMenuMusic()
        }
    }
}


