import SwiftUI

// MARK: - NavigationStack Router View
struct RouterView: View {
    @Environment(AppRouter.self) var router
    @Environment(StoreKitManager.self) var storeKitManager

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
        case .serviceUnavailable:
            ServiceUnavailableView()
                .navigationBarBackButtonHidden(true)
        case .story:
            StoryView()
                .navigationBarBackButtonHidden(true)
        case .main:
            MainView()
                .navigationBarBackButtonHidden(true)
        case .game:
            EmptyView()
                .navigationBarBackButtonHidden(true)
        case .settings:
            SettingsView()
                .navigationBarBackButtonHidden(true)
        case .leaderboard:
            EmptyView()
                .navigationBarBackButtonHidden(true)
        case .market:
            MarketView()
                .navigationBarBackButtonHidden(true)
        case .myInfo:
            MyInfoView()
                .navigationBarBackButtonHidden(true)
        case .gameOver(_, _, _):
            EmptyView()
                .navigationBarBackButtonHidden(true)
        }
    }
}
