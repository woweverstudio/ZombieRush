import SwiftUI

// MARK: - Main Menu View
struct MainMenuView: View {
    @StateObject private var router = AppRouter.shared
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()
            
            VStack {
                // 상단 영역 - 설정 버튼
                HStack {
                    Spacer()
                    
                    NeonIconButton(
                        icon: "gearshape.fill",
                        style: .magenta
                    ) {
                        router.navigate(to: .settings)
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 30)
                
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
                
                // 하단 여백
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 50)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 메인 메뉴 진입 시 메인 메뉴 음악 재생
            AudioManager.shared.playMainMenuMusic()
        }
    }
}

// MARK: - Preview
#Preview {
    MainMenuView()
}
