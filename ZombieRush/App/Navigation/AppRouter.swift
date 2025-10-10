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

        // UI 응답성 우선: 먼저 path에 추가하여 즉시 화면 전환
        path.append(route)

        // 오디오 처리는 메인 스레드에서 처리 (AVAudioPlayer 요구사항)
        DispatchQueue.main.async {
            self.handleAudioTransition(to: route)
        }
    }

    func goBack() {
        guard canGoBack else { return }

        // path에서 제거 (currentRoute는 자동으로 업데이트됨)
        path.removeLast()

        // 뒤로가기 후 음악 변경 (메인 스레드에서)
        DispatchQueue.main.async {
            self.handleAudioTransition(to: self.currentRoute)
        }
    }

    func quitToMain() {
        // UI 응답성 우선: 먼저 path 재설정하여 즉시 화면 전환
        path = [.main]

        // 오디오 처리는 메인 스레드에서 처리 (AVAudioPlayer 요구사항)
        DispatchQueue.main.async {
            self.handleAudioTransition(to: .main)
        }
    }


    // MARK: - 역호환성 유지
    func showGameOver(playTime: Int, score: Int, success: Bool = false) {
        navigate(to: .gameOver(playTime: playTime, score: score, success: success))
    }

    private func handleAudioTransition(to route: Route) {
        switch route {
        case .loading, .story:
            AudioManager.shared.playBackgroundMusic(type: .story)
        case .serviceUnavailable:
            // 서비스 이용 불가 화면에서는 배경음악 재생하지 않음
            AudioManager.shared.stopBackgroundMusic()
        case .main, .settings, .leaderboard, .world:
            AudioManager.shared.playBackgroundMusic(type: .mainMenu)
        case .market, .myInfo:
            AudioManager.shared.playBackgroundMusic(type: .market)
        case .game:
            AudioManager.shared.playBackgroundMusic(type: .game)
        case .gameOver:
            AudioManager.shared.playBackgroundMusic(type: .mainMenu)
        }
    }
}


