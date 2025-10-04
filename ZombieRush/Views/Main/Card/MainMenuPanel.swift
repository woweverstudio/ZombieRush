import SwiftUI
import GameKit

extension MainMenuPanel {
    static let startButton = NSLocalizedString("MAIN_START", tableName: "View", comment: "Start button")
    static let screenTitleMarket = NSLocalizedString("screen_title_market", tableName: "View", comment: "Market title")
    static let screenTitleMyInfo = NSLocalizedString("screen_title_my_info", tableName: "View", comment: "My info title")
    static let screenTitleSettings = NSLocalizedString("screen_title_settings", tableName: "View", comment: "Setting title")
    static let screenTitleStory = NSLocalizedString("screen_title_story", tableName: "View",  comment: "Story title")
}

// MARK: - Main Menu Panel Component
struct MainMenuPanel: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {        
        HStack {
            // 스토리 버튼 (book.fill)
            IconRectButton(iconName: "book.fill", description: MainMenuPanel.screenTitleStory, style: .white) {
                router.navigate(to: .story)
            }
            // 설정 버튼 (gearshape.fill)
            IconRectButton(iconName: "gearshape.fill", description: MainMenuPanel.screenTitleSettings, style: .magenta) {
                router.navigate(to: .settings)
            }

            IconRectButton(iconName: "person.fill", description: MainMenuPanel.screenTitleMyInfo, style: .yellow) {
                router.navigate(to: .myInfo)
            }

            // 상점 버튼 (storefront.fill)
            IconRectButton(iconName: "storefront.fill", description: MainMenuPanel.screenTitleMarket, style: .orange) {
                router.navigate(to: .market)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
