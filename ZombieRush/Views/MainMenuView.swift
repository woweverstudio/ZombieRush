import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainMenuView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    
    @State private var isDataLoaded: Bool = false
    @State private var lastRefreshTime: Date? = nil

    // 말풍선 메시지 결정
    private var gameStartTooltip: String {
        if !gameKitManager.isAuthenticated {
            // 로그인 안됨
            return TextConstants.GameCenter.GameStartTooltips.notLoggedIn
        } else if let playerRank = gameKitManager.playerRank, playerRank <= 3 {
            // 3등 안에 들었음
            return TextConstants.GameCenter.GameStartTooltips.top3
        } else {
            // 로그인 됨 (일반)
            return TextConstants.GameCenter.GameStartTooltips.loggedIn
        }
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            HStack(spacing: 24) {
                // 좌측: 두 개의 카드
                HStack(spacing: 20) {
                    PlayerCard()
                        .frame(maxHeight: .infinity)
                        .frame(width: 200)

                    HallOfFameCard()
                        .frame(maxHeight: .infinity)
                        .frame(minWidth: 230)
                }

                // 우측: 설정과 게임 시작 버튼
                VStack(alignment: .trailing, spacing: 24) {
                    HStack(spacing: 24) {
                        NeonIconButton(icon: "arrow.clockwise", style: .white) {
                            // 데이터 새로고침
                            refreshData()
                        }
                        NeonIconButton(icon: "gearshape.fill", style: .magenta) {
                            router.navigate(to: .settings)
                        }
                    }
                    
                    HStack(spacing: 24) {
                        // 리더보드 버튼
                        NeonIconButton(icon: "trophy.fill", style: .yellow) {
                            router.navigate(to: .leaderboard)
                        }
                    }
                    

                    Spacer()

                    // 메시지 박스
                    VStack(spacing: 0) {
                        Text(gameStartTooltip)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(.vertical, 12)
                            .frame(minHeight: 60)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.leading)
                            .background(
                                SpeechBubble()
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        SpeechBubble()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }

                    NeonButton("GAME START", fullWidth: true) {
                        router.navigate(to: .game)
                    }
                    
                }
                .frame(maxWidth: 240)
            }
            .padding(.vertical, 24)
        }
        .onAppear {
            checkAndLoadData()
        }
    }

    private func checkAndLoadData() {
        if gameKitManager.topThreeEntries.isEmpty || gameKitManager.playerScore == 0 {
            gameKitManager.loadInitialData {
                isDataLoaded = true
            }
        } else {
            isDataLoaded = true
        }
    }

    private func refreshData() {
        // 3초 제한 체크
        let currentTime = Date()
        if let lastTime = lastRefreshTime,
           currentTime.timeIntervalSince(lastTime) < 3.0 {
            // 3초가 지나지 않았으면 무시
            print("⏰ 새로고침은 3초에 한 번만 가능합니다")
            return
        }

        // 마지막 새로고침 시간 업데이트
        lastRefreshTime = currentTime

        // 캐시 초기화 후 데이터 새로고침
        gameKitManager.refreshData {
            // 데이터 새로고침 완료
            isDataLoaded = true

            // 새로고침 완료 피드백 (선택사항)
            print("📊 데이터 새로고침 완료 - 캐시 초기화됨")
        }
    }
}

// MARK: - Preview
#Preview {
    MainMenuView()
}
