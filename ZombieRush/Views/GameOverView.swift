import SwiftUI

struct GameOverView: View {
    let playTime: TimeInterval
    let score: Int
    let wave: Int
    let isNewRecord: Bool
    let onRestart: () -> Void
    let onQuit: () -> Void
    
    @Environment(GameKitManager.self) var gameKitManager
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 20) {
                // 헤더 섹션
                headerSection
                
                // 콘텐츠 섹션 (LeaderBoard 스타일)
                contentSection
                
                // 버튼 섹션
                buttonSection
            }
            .padding()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            BackButton(style: .cyan) {
                onQuit()
            }
            
            Spacer()
            
            if isNewRecord {
                SectionTitle(NSLocalizedString("GAME_OVER_NEW_RECORD", comment: "New record title"), style: .yellow, size: 28)
            } else {
                SectionTitle(TextConstants.GameOver.title, style: .cyan, size: 28)
            }
            
            Spacer()
            
            // 투명 버튼으로 중앙 정렬 유지
            BackButton(style: .cyan) {}
                .opacity(0)
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        HStack(spacing: 20) {
            // 좌측: 플레이어 프로필과 게임 데이터 카드
            gameDataCard
            
            // 우측: 개인 랭킹 카드
            personalRankingCard
        }
    }
    
    // MARK: - Button Section
    private var buttonSection: some View {
        HStack(spacing: 20) {
            NeonButton(TextConstants.GameOver.quitButton, style: .cyan, fullWidth: true) {
                onQuit()
            }

            NeonButton(TextConstants.GameOver.restartButton, style: .magenta, fullWidth: true) {
                onRestart()
            }
        }
    }
    
    // MARK: - Game Data Card (PlayerProfile 스타일)
    private var gameDataCard: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 프로필 섹션
            profileSection
            
            // 게임 데이터 섹션
            gameStatsSection
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan, lineWidth: 2)
                        .shadow(color: Color.cyan, radius: 8, x: 0, y: 0)
                )
        )
        .shadow(color: Color.cyan.opacity(0.3), radius: 15, x: 0, y: 0)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        HStack(spacing: 15) {
            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            // 프로필 이미지
            Group {
                if let playerPhoto = gameKitManager.playerPhoto {
                    Image(uiImage: playerPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: gameKitManager.isAuthenticated ? "person.crop.circle.fill" : "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 40, height: 40)
            */

            // 임시 플레이스홀더
            Group {
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.cyan, radius: 3, x: 0, y: 0)
            
                // TODO: GameKitManager 리팩토링 후 재활성화
                /*
                // 닉네임
                VStack(alignment: .leading, spacing: 2) {
                    Text(gameKitManager.playerDisplayName)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.cyan)
                        .lineLimit(1)
                */

                // 임시 닉네임
                VStack(alignment: .leading, spacing: 2) {
                    Text("Player")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.cyan)
                        .lineLimit(1)
                
                // TODO: GameKitManager 리팩토링 후 재활성화
                /*
                Text(gameKitManager.isAuthenticated ? NSLocalizedString("GAME_OVER_GAME_CENTER", comment: "Game Center label") : NSLocalizedString("GAME_OVER_GUEST", comment: "Guest label"))
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                */

                // 임시 상태 표시
                Text("Guest")
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // MARK: - Game Stats Section
    private var gameStatsSection: some View {
        HStack {
            Spacer()
            
            // TIME 섹션
            VStack(spacing: 8) {
                SectionTitle(NSLocalizedString("GAME_OVER_TIME_LABEL", comment: "Time label"), style: .cyan, size: 16)
                
                Text(formatTime(playTime))
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: Color.cyan, radius: 5, x: 0, y: 0)
            }
            
            Spacer()
            
            // KILLS 섹션
            VStack(spacing: 8) {
                SectionTitle(NSLocalizedString("GAME_OVER_KILLS_LABEL", comment: "Kills label"), style: .cyan, size: 16)
                
                Text("\(score)")
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: Color.cyan, radius: 5, x: 0, y: 0)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Personal Ranking Card
    private var personalRankingCard: some View {
        VStack {
            // 랭크 리스트 타이틀
            SectionTitle(NSLocalizedString("GAME_OVER_MY_RECORDS_TITLE", comment: "My records title"), style: .magenta, size: 20)
                .padding(.vertical, 10)
            
            // 개인 랭크 리스트 (ScrollView로 10개 표시)
            ScrollView {
                LazyVStack(spacing: 8) {
                    let records = GameStateManager.shared.getPersonalRecords()
                    
                    if records.isEmpty {
                        // 기록이 없을 때
                        Text(NSLocalizedString("GAME_OVER_NO_RECORDS", comment: "No records message"))
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        // 기록이 있을 때
                        ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                            rankRow(
                                rank: "\(index + 1)",
                                time: record.formattedTime,
                                zombies: "\(record.zombieKills)"
                            )
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.magenta, lineWidth: 2)
                        .shadow(color: Color.magenta, radius: 8, x: 0, y: 0)
                )
        )
        .shadow(color: Color.magenta.opacity(0.3), radius: 15, x: 0, y: 0)
    }
    
    // MARK: - Rank Row
    private func rankRow(rank: String, time: String, zombies: String) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.magenta)
                .frame(width: 40, alignment: .leading)
            
            Text(time)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(zombies)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 15)
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    GameOverView(
        playTime: 125,
        score: 42,
        wave: 5,
        isNewRecord: false,
        onRestart: {},
        onQuit: {}
    )
    .preferredColorScheme(.dark)
}
