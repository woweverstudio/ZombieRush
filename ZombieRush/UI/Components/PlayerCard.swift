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
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 0)
    }
    
    private var phoneLayout: some View {
        VStack(spacing: 12) {
            // 로그인된 경우 - 플레이어 정보 표시
            Spacer()
            HStack {
//                profileImage(size: 24) // 프로필 이미지
                playerName // 플레이어 이름
            }
            servivalTime // 최대 생존시간
            rankAndKills // 랭크 & 처치수
            
            characterSkin(padding: 16) // 캐릭터 스킨
        }
    }
    
    private var padLayout: some View {
        HStack {
            Spacer()
            // 로그인된 경우 - 플레이어 정보 표시
            VStack(spacing: 24) {
                profileImage(size: 48) // 프로필 이미지
                playerName // 플레이어 이름
                servivalTime // 최대 생존시간
                rankAndKills // 랭크 & 처치수
            }
            Spacer()
            
            characterSkin(padding: 24) // 캐릭터 스킨
            Spacer()
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
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .lineLimit(2)
            .truncationMode(.tail)
            .padding(8)
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
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.7))
        }
    }
    
    private var rankAndKills: some View {
        HStack(spacing: 20) {
            // 랭킹
            if let playerRank = gameKitManager.playerRank {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("#\(playerRank)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                    Text(TextConstants.PlayerCard.rankLabel)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.7))
                }
            } else {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("-")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(TextConstants.PlayerCard.rankLabel)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.7))
                }
            }
            
            // 킬 수
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(playerBestKills)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                
                Text(TextConstants.PlayerCard.killsLabel)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
    }
    
    private func characterSkin(padding: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: 200)
            .padding(padding)
            
    }
}

#Preview {
    PlayerCard()
}
