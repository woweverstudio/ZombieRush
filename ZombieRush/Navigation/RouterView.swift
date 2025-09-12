import SwiftUI

// MARK: - NavigationStack Router View
struct RouterView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameStateManager.self) var gameStateManager

    var body: some View {
        @Bindable var bRouter = router
        NavigationStack(path: $bRouter.path) {
            // 초기 화면
            LoadingView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
    }


    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .loading:
            LoadingView()
                .navigationBarBackButtonHidden(true)
        case .mainMenu:
            MainMenuView()
                .navigationBarBackButtonHidden(true)
        case .game:
            GameView()
                .navigationBarBackButtonHidden(true)
        case .settings:
            SettingsView()
                .navigationBarBackButtonHidden(true)
        case .leaderboard:
            LeaderBoardView()
                .navigationBarBackButtonHidden(true)
        case .gameOver(let playTime, let score, let success):
            GameOverView(
                playTime: playTime,
                score: score,
                success: success,
                onQuit: {
                    router.quitToMainMenu()
                }
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}
