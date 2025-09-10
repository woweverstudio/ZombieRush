import SwiftUI

// MARK: - Main Menu View
struct MainMenuView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()
            
            VStack {
                // 상단 영역 - 설정 및 리더보드 버튼
                HStack {
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // 리더보드 버튼
                        NeonIconButton(icon: "crown.fill", style: .cyan) {
                            router.navigate(to: .leaderboard)
                        }
                        
                        // 설정 버튼
                        NeonIconButton(icon: "gearshape.fill", style: .magenta) {
                            router.navigate(to: .settings)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // 중앙 영역 - 게임 타이틀
                GameTitle()
                
                Spacer()
                
                // 하단 영역 - 게임 시작 버튼
                NeonButton("GAME START") {
                    router.navigate(to: .game)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainMenuView()
}
