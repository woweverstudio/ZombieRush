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
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        PlayerInfoCard()
                        JobCard()
                        StatsCard()
                        MainMenuPanel()
                    }
                    .padding(.horizontal, 18)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                
                Spacer()
                // 게임 시작 버튼
                PrimaryButton(title: MainMenuPanel.startButton, style: .cyan, fullWidth: true) {
                    
                }
                .padding(18)
            }
        }
    }
}


// MARK: - Preview
#Preview {
    MainView()
}
