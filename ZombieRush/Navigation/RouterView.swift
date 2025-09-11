import SwiftUI

// MARK: - Main Router View
struct RouterView: View {
    private let gameStateManager: GameStateManager
    @Environment(AppRouter.self) var router
    
    init(gameStateManager: GameStateManager) {
        self.gameStateManager = gameStateManager
    }
    
    var body: some View {
        // ZStack으로 전환 애니메이션 지원
        ZStack {
            Group {
                switch router.currentRoute {
                case .loading:
                    LoadingView()
                        .id("loading")
                case .mainMenu:
                    MainMenuView()
                        .id("mainMenu")
                case .game:
                    GameView(gameStateManager: self.gameStateManager)
                        .id("game")
                case .settings:
                    SettingsView()
                        .id("settings")
                case .leaderboard:
                    LeaderBoardView()
                        .id("leaderboard")
                case .gameOver:
                    GameOverView(
                        playTime: router.currentGameData?.playTime ?? 0,
                        score: router.currentGameData?.score ?? 0,
                        success: router.currentGameData?.success ?? false,
                        onQuit: {
                            router.quitToMainMenu()
                        }
                    )
                    .id("gameOver")
                }
            }
            .transition(getTransition())
            .animation(.easeInOut(duration: UIConstants.Animation.transitionDuration), value: router.currentRoute)
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
    }
    
    // MARK: - Transition Animation
    private func getTransition() -> AnyTransition {
        switch router.navigationDirection {
        case .forward:
            // 새 화면 진입: 오른쪽에서 들어오고, 왼쪽으로 나감
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            // 뒤로 가기: 왼쪽에서 들어오고, 오른쪽으로 나감
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
}
