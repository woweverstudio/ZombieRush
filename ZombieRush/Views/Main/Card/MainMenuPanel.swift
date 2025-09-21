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
                NeonIconButton(icon: "book.fill", style: .white) {
                    router.navigate(to: .story)
                }
                // 설정 버튼 (gearshape.fill)
                NeonIconButton(icon: "gearshape.fill", style: .magenta) {
                    router.navigate(to: .settings)
                }
            }

            HStack(spacing: 24) {
                // 내 정보 버튼 (person.fill)
                NeonIconButton(icon: "person.fill", style: .yellow) {
                    router.navigate(to: .myInfo(category: .jobs))
                }

                // 상점 버튼 (storefront.fill)
                NeonIconButton(icon: "storefront.fill", style: .orange) {
                    router.navigate(to: .market)
                }
            }

            Spacer()

            // 메시지 박스
//            VStack(spacing: 0) {
//                Text(gameStartTooltip)
//                    .font(.system(size: 12, weight: .medium, design: .monospaced))
//                    .foregroundColor(.white)
//                    .lineLimit(2)
//                    .padding(.vertical, 12)
//                    .frame(minHeight: 60)
//                    .frame(maxWidth: .infinity)
//                    .multilineTextAlignment(.leading)
//                    .background(
//                        SpeechBubble()
//                            .fill(Color.black.opacity(0.4))
//                            .overlay(
//                                SpeechBubble()
//                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                            )
//                    )
//            }

            // 테스트 버튼 (EXP +10)
            Button(action: {
                Task {
                    let result = await userStateManager.addExperience(10)
                    if result.leveledUp {
                        print("🎉 레벨업! \(result.levelsGained)레벨 상승, 포인트 +\(result.levelsGained * 3)")
                    } else {
                        print("📈 경험치 +10 (현재 레벨: \(userStateManager.level?.currentLevel ?? 0))")
                    }
                }
            }) {
                Text("EXP +10")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.bottom, 8)

            // 게임 시작 버튼
            NeonButton(TextConstants.Main.startButton, fullWidth: true) {
                router.navigate(to: .game)
            }
        }
        .frame(maxWidth: isPhoneSize ? 240 : 300)
    }
}
