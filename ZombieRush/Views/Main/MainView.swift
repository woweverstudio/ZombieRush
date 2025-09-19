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
        } else if true {
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
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(UserStateManager.self) var userStateManager
    @Environment(JobsStateManager.self) var jobsStateManager

    // JobsStateManager의 개별 스탯 프로퍼티 사용 (옵셔널 체이닝 완전 제거)

    var body: some View {
        ZStack {
            CardBackground()

            VStack(spacing: 16) {
                // 상단: 프로필 정보
                HStack(spacing: 12) {
                    // GameKit 프로필 이미지
                    ZStack {
                        if let playerPhoto = userStateManager.userImage {
                            Image(uiImage: playerPhoto)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: 40, height: 40)

                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(userStateManager.nickname)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("네모나라의 수호자")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                // 중간: 기본 스탯 정보
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))

                            if let levelInfo = userStateManager.currentLevel {
                                Text("Lv. \(levelInfo.currentLevel)")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            } else {
                                Text("Lv. --")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            Spacer()
                        }
                        
                        // 경험치 바
                        VStack(alignment: .leading, spacing: 8) {
                            if let levelInfo = userStateManager.currentLevel {
                                let currentLevelExp = levelInfo.currentExp - levelInfo.levelMinExp
                                let requiredExp = levelInfo.expToNextLevel
                                let percentage = Int(levelInfo.progress * 100)

                                Text("네모 구출 \(currentLevelExp)/\(requiredExp)")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 4) {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 10)

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(width: 150 * levelInfo.progress, height: 10)
                                    }
                                    .frame(width: 150)
                                    
                                    Text("(\(percentage)%)")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.green)
                                }
                                
                            } else {
                                // 로딩 중이거나 데이터 없을 때
                                HStack(spacing: 4) {
                                    Text("네모 구출 로딩중...")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.6))

                                    Text("(0%)")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                }

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 10)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 8, height: 10)
                                }
                                .frame(width: 150)
                            }
                        }
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                    
                VStack(alignment: .leading, spacing: 8) {
                    StatRow(icon: "heart.fill", label: "체력", value: "\(jobsStateManager.hp)", color: .red)
                    StatRow(icon: "bolt.fill", label: "에너지", value: "\(jobsStateManager.energy)", color: .blue)
                    StatRow(icon: "shoeprints.fill", label: "이동속도", value: "\(jobsStateManager.move)", color: .green)
                    StatRow(icon: "bolt.horizontal.fill", label: "공격속도", value: "\(jobsStateManager.attackSpeed)", color: .yellow)
                    StatRow(icon: "flame.fill", label: "궁극기", value: jobsStateManager.currentJobName, color: .orange)
                }
                
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Stat Row Component
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    init(icon: String, label: String, value: String, color: Color) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))
                .frame(width: 20, alignment: .leading)

            Text("\(label):")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 50, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Current Class Card
struct CurrentClassCard: View {
    @Environment(JobsStateManager.self) var jobsStateManager

    // JobsStateManager의 currentJobName 직접 사용

    var body: some View {
        ZStack {
            CardBackground()
            VStack {
                Image("sample")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text(jobsStateManager.currentJobName)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

// MARK: - Selected Weapon Card
struct SelectedWeaponCard: View {
    var body: some View {
        ZStack {
            CardBackground()

            VStack {
                Image("sample_weapon")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                Text("딱총나무 지팡이")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
            }
            .padding()
        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
