import SwiftUI
import GameKit

// MARK: - Main Menu Panel Component
struct MainMenuPanel: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(UserStateManager.self) var userStateManager

    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    // 말풍선 메시지 결정
    private var gameStartTooltip: String {
        if !gameKitManager.isAuthenticated {
            // 로그인 안됨
            return TextConstants.GameCenter.GameStartTooltips.notLoggedIn
        } else if true {
            // 3등 안에 들었음
            return TextConstants.GameCenter.GameStartTooltips.top3
        } else {
            // 로그인 됨 (일반)
            return TextConstants.GameCenter.GameStartTooltips.loggedIn
        }
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 24) {
            HStack(spacing: 24) {
                // 스토리 버튼 (book.fill)
                IconButton(iconName: "book.fill", style: .white) {
                    router.navigate(to: .story)
                }
                // 설정 버튼 (gearshape.fill)
                IconButton(iconName: "gearshape.fill", style: .magenta) {
                    router.navigate(to: .settings)
                }
            }

            HStack(spacing: 24) {
                // 내 정보 버튼 (person.fill)
                IconButton(iconName: "person.fill", style: .yellow) {
                    router.navigate(to: .myInfo(category: .jobs))
                }

                // 상점 버튼 (storefront.fill)
                IconButton(iconName: "storefront.fill", style: .orange) {
                    router.navigate(to: .market)
                }
            }

            Spacer()

            // 메시지 박스
            VStack(spacing: 0) {
                Text(gameStartTooltip)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .lineLimit(2)
                    .padding(.vertical, 12)
                    .frame(minHeight: 60)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .background(
                        SpeechBubble()
                            .fill(Color.dsSurface)
                            .overlay(
                                SpeechBubble()
                                    .stroke(Color.dsTextSecondary.opacity(0.3), lineWidth: 1)
                            )
                    )
            }

            // 게임 시작 버튼
            NeonButton(TextConstants.Main.startButton, fullWidth: true) {
                router.navigate(to: .game)
            }
        }
        .frame(maxWidth: isPhoneSize ? 240 : 300)
    }
}
