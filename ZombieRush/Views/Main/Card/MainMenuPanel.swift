import SwiftUI
import GameKit

extension MainMenuPanel {
    static let gameStartTooltipNotLoggedIn = NSLocalizedString("GAME_START_TOOLTIP_NOT_LOGGED_IN", comment: "Game start tooltip when not logged in")
    static let gameStartTooltipTop3 = NSLocalizedString("GAME_START_TOOLTIP_TOP3", comment: "Game start tooltip when in top 3")
    static let gameStartTooltipLoggedIn = NSLocalizedString("GAME_START_TOOLTIP_LOGGED_IN", comment: "Game start tooltip when logged in")
    static let startButton = NSLocalizedString("MAIN_START", comment: "Start button")
    static let storyButton = NSLocalizedString("story_button", tableName: "Main", comment: "Story button label")
    static let settingsButton = NSLocalizedString("settings_button", tableName: "Main", comment: "Settings button label")
    static let myInfoButton = NSLocalizedString("my_info_button", tableName: "Main", comment: "My Info button label")
    static let marketButton = NSLocalizedString("market_button", tableName: "Main", comment: "Market button label")
}

// MARK: - Main Menu Panel Component
struct MainMenuPanel: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    // 말풍선 메시지 결정
    private var gameStartTooltip: String {
        if !gameKitManager.isAuthenticated {
            // 로그인 안됨
            return MainMenuPanel.gameStartTooltipNotLoggedIn
        } else if true {
            // 3등 안에 들었음
            return MainMenuPanel.gameStartTooltipTop3
        } else {
            // 로그인 됨 (일반)
            return MainMenuPanel.gameStartTooltipLoggedIn
        }
    }

    var body: some View {        
        HStack {
            // 스토리 버튼 (book.fill)
            IconRectButton(iconName: "book.fill", description: MainMenuPanel.storyButton, style: .white) {
                router.navigate(to: .story)
            }
            // 설정 버튼 (gearshape.fill)
            IconRectButton(iconName: "gearshape.fill", description: MainMenuPanel.settingsButton, style: .magenta) {
                router.navigate(to: .settings)
            }

            IconRectButton(iconName: "person.fill", description: MainMenuPanel.myInfoButton, style: .yellow) {
                router.navigate(to: .myInfo)
            }

            // 상점 버튼 (storefront.fill)
            IconRectButton(iconName: "storefront.fill", description: MainMenuPanel.marketButton, style: .orange) {
                router.navigate(to: .market)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
