import SwiftUI
import GameKit

// MARK: - Global Ranking Card Component
struct GlobalRankingCard: View {
    @ObservedObject var gameKitManager: GameKitManager
    
    var body: some View {
        VStack {
            Spacer()
            
            // 타이틀
            SectionTitle("Global Top 100", style: .magenta, size: 18)
                .padding(.vertical, 10)
            
            // 랭킹 리스트
            rankingList
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.magenta, lineWidth: 2)
                        .shadow(color: Color.magenta, radius: 8, x: 0, y: 0)
                )
        )
        .shadow(color: Color.magenta.opacity(0.3), radius: 15, x: 0, y: 0)
    }
    
    // MARK: - Ranking List
    private var rankingList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if gameKitManager.isLoadingLeaderboard {
                    loadingView
                } else if !gameKitManager.isAuthenticated {
                    sampleDataView
                } else if gameKitManager.globalLeaderboard.isEmpty {
                    emptyDataView
                } else {
                    realDataView
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }
    
    // MARK: - Sample Data View (Guest Users)
    private var sampleDataView: some View {
        VStack(spacing: 8) {
            // 안내 메시지
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.yellow.opacity(0.8))
                Text("Sample Rankings")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.yellow.opacity(0.8))
            }
            .padding(.bottom, 5)
            
            // 샘플 랭킹 데이터
            ForEach(Array(sampleData.enumerated()), id: \.offset) { index, data in
                GlobalRankRow(
                    rank: data.0,
                    nickname: data.1,
                    time: data.2,
                    kills: data.3,
                    isMe: false,
                    profileImage: nil
                )
                .opacity(0.7) // 샘플 데이터임을 나타내는 투명도
            }
            
            // 하단 안내
            Text("Sign in to see real rankings")
                .font(.system(size: 10, weight: .light, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 5)
        }
    }
    
    // MARK: - Empty Data View (Authenticated but no data)
    private var emptyDataView: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.5))
            Text("No rankings yet")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            Text("Play games to see rankings!")
                .font(.system(size: 12, weight: .light, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
    }
    
    // MARK: - Real Data View (Authenticated with data)
    private var realDataView: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(gameKitManager.globalLeaderboard.enumerated()), id: \.offset) { index, entry in
                let rank = entry.rank
                let playerName = entry.player.displayName
                let totalScore = entry.score
                let playerID = entry.player.gamePlayerID
                
                // 16비트 인코딩에서 시간과 킬 수 분리
                let timeInSeconds = Int((totalScore >> 16) & 0xFFFF)
                let kills = Int(totalScore & 0xFFFF)
                let formattedTime = String(format: "%02d:%02d", timeInSeconds / 60, timeInSeconds % 60)
                
                GlobalRankRow(
                    rank: rank,
                    nickname: playerName,
                    time: formattedTime,
                    kills: "\(kills)",
                    isMe: entry.player.gamePlayerID == gameKitManager.playerID,
                    profileImage: gameKitManager.profileImages[playerID]
                )
                .onAppear {
                    // 마지막에서 5번째 항목이 나타나면 더 많은 데이터 로드
                    if index == gameKitManager.globalLeaderboard.count - 5 {
                        Task {
                            await gameKitManager.loadMoreLeaderboard()
                        }
                    }
                }
            }
            
            // 로딩 인디케이터 (더 많은 데이터를 로드할 수 있는 경우)
            if gameKitManager.globalLeaderboard.count < 100 && gameKitManager.globalLeaderboard.count >= 20 {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Loading more...")
                        .font(.system(size: 10, weight: .light, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 10)
                .onAppear {
                    Task {
                        await gameKitManager.loadMoreLeaderboard()
                    }
                }
            }
        }
    }
    
    // MARK: - Sample Data
    private var sampleData: [(Int, String, String, String)] {
        [
            (1, "ZombieHunter", "06:45", "189"),
            (2, "ProGamer", "05:58", "167"),
            (3, "NightSlayer", "05:23", "156"),
            (4, "DeadShot", "04:45", "134"),
            (5, "Survivor", "04:12", "125")
        ]
    }
}

// MARK: - Global Rank Row Component
struct GlobalRankRow: View {
    let rank: Int
    let nickname: String
    let time: String
    let kills: String
    let isMe: Bool
    let profileImage: UIImage?
    
    var body: some View {
        HStack(spacing: 10) {
            // 순위
            Text("\(rank)")
                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                .foregroundColor(rankColor)
                .frame(width: 30)
            
            // 프로필 이미지
            Group {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 22, height: 22)
            .clipShape(Circle())
            
            // 닉네임
            Text(nickname)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // 시간과 킬수
            VStack(alignment: .trailing, spacing: 4) {
                Text(time)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\(kills) kills")
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isMe ? 1 : 0)
                )
        )
    }
    
    // MARK: - Computed Properties
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.8, green: 0.8, blue: 0.8) // 은색
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // 동색
        default: return .white.opacity(0.8)
        }
    }
    
    private var backgroundColor: Color {
        if isMe {
            return Color.magenta.opacity(0.15)
        } else {
            return Color.black.opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        return isMe ? Color.magenta : Color.clear
    }
}

// MARK: - Preview
#Preview {
    GlobalRankingCard(gameKitManager: GameKitManager.shared)
        .preferredColorScheme(.dark)
}
