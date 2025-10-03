import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager

    @State private var isDataLoaded: Bool = false
    @State private var lastRefreshTime: Date? = nil


    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()
            VStack(spacing: 12) {
                PlayerInfoCard()
                JobCard()
                StatsCard()
                
                // 메뉴 패널
                MainMenuPanel()
            }
            .padding(.vertical, 24)
            .padding(.horizontal, isPhoneSize ? 16 : 24)
        }
    }
}


// MARK: - Preview
#Preview {
    MainView()
}
