import SwiftUI

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @StateObject private var router = AppRouter.shared
    @StateObject private var gameKitManager = GameKitManager.shared
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground(opacity: 0.5)
                .ignoresSafeArea()
                .task {
                    await loadLeaderboardData()
                }

            VStack {
                // 상단: 헤더
                headerSection
                
                // 중단: 프로필과 랭킹 카드
                contentSection
            }
            .padding()
        }
        .onDisappear {
            // 리더보드 화면을 벗어날 때 GKAccessPoint 비활성화
            GameCenterAccessPointView.deactivateAccessPoint()
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
            
            // Game Center Access Point
            GameCenterAccessPointView()
                .frame(width: 44, height: 44)
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        HStack(spacing: 20) {
            // 좌측: 플레이어 프로필 카드
            PlayerProfileCard(gameKitManager: gameKitManager)
            
            // 우측: 글로벌 랭킹 카드
            GlobalRankingCard(gameKitManager: gameKitManager)
        }
    }
    
    // MARK: - Data Loading
    private func loadLeaderboardData() async {
        do {
            try await gameKitManager.loadGlobalLeaderboard()
        } catch {
            // 리더보드 로드 실패는 샘플 데이터로 대체됨
        }
    }
}

// MARK: - Preview
#Preview {
    LeaderBoardView()
        .preferredColorScheme(.dark)
}