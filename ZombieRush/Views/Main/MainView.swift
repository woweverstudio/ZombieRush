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

            HStack(spacing: 12) {
                // 좌측: 플레이어 정보 통합 카드 (JobsStateManager의 스탯 사용)
                PlayerInfoCard()

                // 우측: 현재 클래스 & 무기 정보 + 메뉴 버튼들
                VStack(spacing: 12) {
                    // 현재 직업 정보 (JobsStateManager의 탭 상태 사용)
                    JobCard()

                    // 스탯 관리 카드
                    StatsCard()
                }

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
