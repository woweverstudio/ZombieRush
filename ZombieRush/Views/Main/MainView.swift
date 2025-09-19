import SwiftUI
import GameKit

// MARK: - Main Menu View
struct MainView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @Environment(JobsStateManager.self) var jobsStateManager

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
                // 좌측: 플레이어 정보 통합 카드 (JobsStateManager의 스탯 사용)
                PlayerInfoCard()

                // 우측: 현재 클래스 & 무기 정보 + 메뉴 버튼들
                VStack(spacing: 12) {
                    // 현재 직업 정보 (JobsStateManager의 탭 상태 사용)
                    JobCard()

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

    var body: some View {
        ZStack {
            CardBackground()

            VStack(spacing: 16) {
                profileInfo

                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(maxHeight: .infinity)

                levelInfo
                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(maxHeight: .infinity)
                statInfo
            }
            .padding()
        }
    }
    
    var profileInfo: some View {
        HStack(spacing: 12) {
            // GameKit 프로필 이미지
            if let playerPhoto = userStateManager.userImage {
                Image(uiImage: playerPhoto)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
        

            VStack(alignment: .leading, spacing: 4) {
                Text(userStateManager.nickname)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("네모나라의 수호자")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }
    
    var levelInfo: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))

                    if let levelInfo = userStateManager.level {
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
                    if let levelInfo = userStateManager.level {
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
                        
                    }
                }
            }
        }
    }
    
    var statInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            StatRow(icon: "heart.fill", label: "체력", value: "\(jobsStateManager.hp)", color: .red)
            StatRow(icon: "bolt.fill", label: "에너지", value: "\(jobsStateManager.energy)", color: .blue)
            StatRow(icon: "shoeprints.fill", label: "이동속도", value: "\(jobsStateManager.move)", color: .green)
            StatRow(icon: "bolt.horizontal.fill", label: "공격속도", value: "\(jobsStateManager.attackSpeed)", color: .yellow)
            StatRow(icon: "flame.fill", label: "궁극기", value: "궁극기 이름 들어감", color: .orange)
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
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 50, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Job Card (TabView로 모든 job 표시)
struct JobCard: View {
    @Environment(JobsStateManager.self) var jobsStateManager

    // 이전/다음 탭으로 이동
    private func previousTab() {
        withAnimation {
            if let currentIndex = JobType.allCases.firstIndex(of: jobsStateManager.selectedJobType) {
                let prevIndex = currentIndex > 0 ? currentIndex - 1 : JobType.allCases.count - 1
                jobsStateManager.currentJobs.selectedJob = JobType.allCases[prevIndex].rawValue
            }
        }
    }

    private func nextTab() {
        withAnimation {
            if let currentIndex = JobType.allCases.firstIndex(of: jobsStateManager.selectedJobType) {
                let nextIndex = currentIndex < JobType.allCases.count - 1 ? currentIndex + 1 : 0
                jobsStateManager.currentJobs.selectedJob = JobType.allCases[nextIndex].rawValue
            }
        }
    }

    var body: some View {
        @Bindable var jobState = jobsStateManager
        ZStack {
            CardBackground()
            
            // TabView로 job 표시 (indicator 제거)
            TabView(selection: $jobState.currentJobs.selectedJob) {
                ForEach(JobType.allCases, id: \.self) { jobType in
                    JobDetailView()
                        .tag(jobType.rawValue)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack {
                Button(action: previousTab) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(20)
                        .clipShape(Rectangle())
                }

                Spacer()

                // 우측 chevron 버튼
                Button(action: nextTab) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(20)
                        .clipShape(Rectangle())
                }
            }
        }
    }
}

// MARK: - 개별 Job 상세 정보 View
struct JobDetailView: View {
    @Environment(JobsStateManager.self) var jobsStateManager

    var body: some View {
        VStack(spacing: 8) {
            Image("sample")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100)
                
            // Job 이름 (간단하게 표시)
            Text(jobsStateManager.currentJobName)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Selected Weapon Card
struct SelectedWeaponCard: View {
    var body: some View {
        ZStack {
            CardBackground()

        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
