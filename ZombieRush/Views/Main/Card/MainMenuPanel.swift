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
        VStack(spacing: 24) {
            HStack(spacing: 24) {
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
            .frame(maxWidth: .infinity, alignment: .center)
            Spacer()

//            // 메시지 박스
//            VStack(spacing: 0) {
//                Text(gameStartTooltip)
//                    .font(.system(size: 12, weight: .medium, design: .monospaced))
//                    .foregroundColor(Color.dsTextPrimary)
//                    .lineLimit(2)
//                    .padding(.vertical, 12)
//                    .frame(minHeight: 60)
//                    .frame(maxWidth: .infinity)
//                    .multilineTextAlignment(.leading)
//                    .background(
//                        SpeechBubble()
//                            .fill(Color.dsSurface)
//                            .overlay(
//                                SpeechBubble()
//                                    .stroke(Color.dsTextSecondary.opacity(0.3), lineWidth: 1)
//                            )
//                    )
//            }

            // 게임 시작 버튼
            PrimaryButton(title: MainMenuPanel.startButton, style: .cyan, fullWidth: true) {
                Task {
                    let request = AddExperienceRequest(expToAdd: 10)
                    let _ = await useCaseFactory.addExperience.execute(request)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
