import SwiftUI

// MARK: - Main Router View
struct RouterView: View {
    @StateObject private var router = AppRouter.shared
    
    var body: some View {
        ZStack {
            // 메인 컨텐츠
            Group {
                switch router.currentRoute {
                case .mainMenu:
                    MainMenuView()
                case .game:
                    GameView()
                case .settings:
                    SettingsView()
                case .leaderboard:
                    LeaderBoardView()
                case .gameOver:
                    GameOverView(
                        playTime: router.currentGameData?.playTime ?? 0,
                        score: router.currentGameData?.score ?? 0,
                        wave: router.currentGameData?.wave ?? 0,
                        isNewRecord: router.currentGameData?.isNewRecord ?? false,
                        onRestart: {
                            router.restart()
                        },
                        onQuit: {
                            router.quitToMainMenu()
                        }
                    )
                }
            }
            .transition(getTransition())
            
            // 전환 중 로딩 오버레이 (필요시)
            if router.isTransitioning {
                Color.black.opacity(0.3)
                    // .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
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

// MARK: - Preview
#Preview {
    RouterView()
}
