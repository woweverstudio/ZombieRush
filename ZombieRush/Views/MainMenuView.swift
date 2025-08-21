import SwiftUI

// MARK: - Main Menu View
struct MainMenuView: View {
    @StateObject private var router = AppRouter.shared
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()
                .ignoresSafeArea()
                
            VStack {
                Spacer()
                // 상단 영역 - 설정 및 리더보드 버튼
                HStack(spacing: 20) {
                    Spacer()
                    
                    // 리더보드 버튼
                    NeonIconButton(
                        icon: "crown.fill",
                        style: .cyan
                    ) {
                        router.navigate(to: .leaderboard)
                    }
                    
                    // 설정 버튼
                    NeonIconButton(
                        icon: "gearshape.fill",
                        style: .magenta
                    ) {
                        router.navigate(to: .settings)
                    }
                }
                
                Spacer()
                
                // 게임 타이틀
                GameTitle()
                    .padding(.bottom, 40)
                
                // 게임 시작 버튼
                VStack(spacing: 20) {
                    NeonButton("GAME START") {
                        router.navigate(to: .game)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainMenuView()
}
