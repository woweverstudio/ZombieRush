import SwiftUI


// MARK: - Loading View



struct LoadingView: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(AppRouter.self) var router
    @Environment(StoreKitManager.self) var storeKitManager

    @State var currentStage: LoadingStage = .checkConfig
    @State var progress: Double = 0.0
    @State var configManager = ConfigManager()

    var body: some View {
        @Bindable var bConfigManager = configManager
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
                            .frame(width: progress * 300, height: 8)
                    }
                    .frame(width: 300)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startLoadingProcess()
        }
        .fullScreenCover(isPresented: $bConfigManager.shouldForceUpdate) {
            // 강제 업데이트 화면 (닫을 수 없음)
            ForceUpdateView()
        }
        .fullScreenCover(isPresented: $bConfigManager.isUnavailableService) {
            // 서비스 이용 불가 화면
            ServiceUnavailableView()
        }
    }
}
