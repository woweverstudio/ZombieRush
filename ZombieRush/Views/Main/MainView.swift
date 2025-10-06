import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    
    @State private var isDataLoaded: Bool = false
    @State private var lastRefreshTime: Date? = nil
    @State private var showGuestPopup: Bool = false


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
                // 게임 시작 버튼
                PrimaryButton(title: MainMenuPanel.startButton, style: .cyan, fullWidth: true) {
                    Task {
                        let request = AddExperienceRequest(expToAdd: 30)
                        let _ = await useCaseFactory.addExperience.execute(request)
                    }
                    
                    
                }
                .padding(18)
            }
        }
        .sheet(isPresented: $showGuestPopup) {
            GuestPopup {
                showGuestPopup = false
            }
        }
        .onAppear {
            // 게스트 유저 확인
            if useCaseFactory.repositories.user.currentUser?.id == "" {
                showGuestPopup = true
            }
        }
    }
}


// MARK: - Preview
#Preview {
    MainView()
}
