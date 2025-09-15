import SwiftUI
import GameKit

struct PlayerCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router

    // GameKit 점수에서 시간과 킬 수 디코딩
    private var playerBestTime: Int {
        return ScoreEncodingUtils.decodeTime(from: gameKitManager.playerScore)
    }

    private var playerBestKills: Int {
        return ScoreEncodingUtils.decodeKills(from: gameKitManager.playerScore)
    }
    
    private var isPhoneSize: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        Group {
            if gameKitManager.isAuthenticated {
                if isPhoneSize { phoneLayout }
                else { padLayout }
                
            } else {
                // 로그인 안 된 경우 - 로그인 메시지 표시
                LoginPromptCard()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 0)
            
    }
    
    private var phoneLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 로그인된 경우 - 플레이어 정보 표시
            HStack(spacing: 12) {
                profileImage(size: 32) // 프로필 이미지
                playerName // 플레이어 이름
            }
            playerLevel
            servivalTime // 최대 생존시간
            rank
            kills
        }
    }
    
    private var padLayout: some View {
        
        // 로그인된 경우 - 플레이어 정보 표시
        VStack(alignment: .leading,spacing: 24) {
            HStack(spacing: 24) {
                profileImage(size: 48) // 프로필 이미지
                playerName // 플레이어 이름
            }
            servivalTime // 최대 생존시간
            rank // 랭크 & 처치수
            kills
            playerLevel
        }
        .frame(maxWidth: .infinity)
    }
    
    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let playerPhoto = gameKitManager.playerPhoto {
                Image(uiImage: playerPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                    )
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.cyan.opacity(0.7))
            }
        }
    }
    
    private var playerName: some View {
        // 플레이어 이름
        Text(gameKitManager.playerDisplayName)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .truncationMode(.tail)
            
    }
    
    private var servivalTime: some View {
        HStack(alignment: .bottom, spacing: 4) {
            // 플레이 시간 (GameKit 점수에서 디코딩)
            let playTime = ScoreEncodingUtils.formatTime(playerBestTime)
            
            Text(playTime)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)
            
            Text(TextConstants.PlayerCard.playTimeLabel)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.7))
        }
    }
    
    private var rank: some View {
        // 랭킹
        if let playerRank = gameKitManager.playerRank {
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(playerRank)")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                Text(TextConstants.PlayerCard.rankLabel)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow.opacity(0.7))
            }
        } else {
            HStack(alignment: .bottom, spacing: 4) {
                Text("-")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Text(TextConstants.PlayerCard.rankLabel)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow.opacity(0.7))
            }
        }
    }
    
    private var kills: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text("\(playerBestKills)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.red)
            
            Text(TextConstants.PlayerCard.killsLabel)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.red.opacity(0.7))
        }
    }
    
    private var playerLevel: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text("5")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Lv")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            
            ZStack(alignment: .leading) {
                // 배경 바
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)

                // 진행 바
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.purple.opacity(0.8))
                    .frame(width: 0.8 * 150, height: 8)
            }
            .frame(width: 150)
        }
    }
}

#Preview {
    PlayerCard()
}
