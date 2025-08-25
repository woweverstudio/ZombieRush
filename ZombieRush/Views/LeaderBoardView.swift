import SwiftUI

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground(opacity: 0.5)
                .ignoresSafeArea()
                .task {
                    await loadLeaderboardData()
                }

            VStack(spacing: 10) {
                headerSection
                contentSection
            }
            .padding()
        }
        .onChange(of: gameKitManager.isAuthenticated) { oldValue, newValue in
            // 인증 상태가 false에서 true로 변경되면 리더보드 다시 로드
            if !oldValue && newValue {
                Task {
                    await loadLeaderboardData()
                }
            }
        }
        .onDisappear {
            // 리더보드 화면을 벗어날 때 처리할 내용이 있으면 여기에 추가
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            BackButton(style: .cyan) {
                router.goBack()
            }
            
            Spacer()
            
            SectionTitle("LEADER BOARD", style: .cyan, size: 28)
            
            Spacer()
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        HStack(spacing: 20) {
            // 좌측: 플레이어 프로필 카드
            PlayerProfileCard()
            
            // 우측: 글로벌 랭킹 카드
            GlobalRankingCard()
        }
    }
    
    // MARK: - Data Loading
    private func loadLeaderboardData() async {
        do {
            try await gameKitManager.loadTop100Leaderboard()
        } catch {
            print("🎮 LeaderBoard: Failed to load top 100 - \(error.localizedDescription)")
            // 인증되지 않은 경우 등 실패 시 샘플 데이터로 대체됨
        }
    }
}

// MARK: - Preview
#Preview {
    LeaderBoardView()
        .preferredColorScheme(.dark)
}
