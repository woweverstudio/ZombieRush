import SwiftUI


// MARK: - Loading View
struct LoadingView: View {
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    
    @Environment(StoreKitManager.self) var storeKitManager
    @Environment(ConfigManager.self) var configManager
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(Processor.self) var processor
    @Environment(AppRouter.self) var router

    var body: some View {
        @Bindable var bindableConfig = configManager
        ZStack {
            // 사이버펑크 배경
            Background(style: .image("background"))

            VStack(spacing: 30) {
                Spacer()

                // 로딩 프로그레스 바
                VStack(spacing: 20) {
                    // 프로그레스 바
                    ZStack(alignment: .leading) {
                        // 배경 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.dsSurface)
                            .frame(height: 8)

                        // 진행 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.magenta.opacity(0.8))
                            .frame(width: processor.progress * 300, height: 8)
                    }
                    .frame(width: 300)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            processor.start(
                useCaseFactory: useCaseFactory,
                configManager: configManager,
                gameKitManager: gameKitManager,
                storeKitManager: storeKitManager
            )
            
            moveNextScreen()
        }
        .fullScreenCover(isPresented: $bindableConfig.shouldForceUpdate) {
            // 강제 업데이트 화면 (닫을 수 없음)
            ForceUpdateView()
        }
        .fullScreenCover(isPresented: $bindableConfig.isUnavailableService) {
            // 서비스 이용 불가 화면
            ServiceUnavailableView()
        }
    }
    
    private func moveNextScreen() {
        if self.router.currentRoute == .loading {
            // 앱 처음 실행인지 확인
            let hasSeenStory = UserDefaults.standard.bool(forKey: "hasSeenStory")

            if hasSeenStory {
                // 이미 본 적이 있으면 메인 화면으로 이동
                self.router.navigate(to: .main)
            } else {
                // 처음이면 스토리 화면으로 이동
                self.router.navigate(to: .story)
            }
        }
    }
}
