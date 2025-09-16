import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainView: View {
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
    
    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            HStack(spacing: 12) {
                // 좌측: 플레이어 정보 통합 카드
                PlayerInfoCard()

                // 우측: 현재 클래스 & 무기 정보 + 메뉴 버튼들
                VStack(spacing: 12) {
                    // 현재 직업 정보
                    CurrentClassCard()
                        
                    // 선택된 무기 정보
                    SelectedWeaponCard()
                }

                // 메뉴 버튼들과 게임 시작
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
                        // 리더보드 버튼 (trophy.fill)
                        NeonIconButton(icon: "trophy.fill", style: .yellow) {
                            router.navigate(to: .leaderboard)
                        }

                        // 상점 버튼 (storefront.fill)
                        NeonIconButton(icon: "storefront.fill", style: .orange) {
                            router.navigate(to: .market)
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

                    // 게임 시작 버튼
                    NeonButton(TextConstants.Main.startButton, fullWidth: true) {
                        router.navigate(to: .game)
                    }

                }
                .frame(maxWidth: isPhoneSize ? 240 : 300)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, isPhoneSize ? 16 : 24)
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
            return
        }

        // 마지막 새로고침 시간 업데이트
        lastRefreshTime = currentTime

        // 캐시 초기화 후 데이터 새로고침
        gameKitManager.refreshData {
            // 데이터 새로고침 완료
            isDataLoaded = true

            // 새로고침 완료 피드백 (선택사항)
        }
    }
}

struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
                    .frame(maxHeight: .infinity)
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

// MARK: - Player Info Card (프로필 + 스탯 통합)
struct PlayerInfoCard: View {
    var body: some View {
        ZStack {
            CardBackground()

            VStack(spacing: 16) {
                // 상단: 프로필 정보
                HStack(spacing: 12) {
                    // 프로필 이미지
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 60, height: 60)

                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("플레이어")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text("네모나라의 수호자")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                // 하단: 레벨 & 네모구출 정보
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))

                            Text("Lv. 1")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "square.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))

                            Text("네모구출: 0")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    // 경험치 바
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("0/100")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.green)
                                .frame(width: 24, height: 8) // 0/100 = 24% 진행
                        }
                        .frame(width: 80)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Current Class Card
struct CurrentClassCard: View {
    var body: some View {
        ZStack {
            CardBackground()

            HStack(spacing: 12) {
                // 캐릭터 스킨 (임시로 마법사 아이콘)
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 50, height: 50)

                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("마법사")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("각진 힘의 수호자")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // 궁극기 아이콘
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 40, height: 40)

                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Selected Weapon Card
struct SelectedWeaponCard: View {
    var body: some View {
        ZStack {
            CardBackground()

            HStack(spacing: 12) {
                // 무기 아이콘
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 40, height: 40)

                    Image(systemName: "wand.and.rays")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("기본 마법봉")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("각진 마법의 기본")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // 공격력 표시
                VStack(alignment: .trailing, spacing: 2) {
                    Text("공격력")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))

                    Text("25")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
