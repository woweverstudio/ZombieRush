import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AlertManager.self) var alertManager
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
                    VStack(spacing: UIConstants.Spacing.x16) {
                        PlayerInfoCard()
                        JobCard()
                        StatsCard()
                        MainMenuPanel()
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                Spacer()

                // CTA: 게임 시작 버튼
                PrimaryButton(title: MainMenuPanel.startButton, style: .cyan, fullWidth: true) {
                    router.navigate(to: .world)
                }
                .ctaButtonSpacing()
            }
            .pagePadding()
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
