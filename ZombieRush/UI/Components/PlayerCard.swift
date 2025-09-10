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

    var body: some View {
        ZStack {
            // 카드 배경
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 0)

            VStack(spacing: 20) {
                if gameKitManager.isAuthenticated {
                    // 로그인된 경우 - 플레이어 정보 표시
                    VStack(spacing: 16) {
                        // 프로필 이미지
                        Group {
                            if let playerPhoto = gameKitManager.playerPhoto {
                                Image(uiImage: playerPhoto)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                                    )
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.cyan.opacity(0.7))
                            }
                        }

                        // 플레이어 이름
                        Text(gameKitManager.playerDisplayName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        // 플레이 시간 (GameKit 점수에서 디코딩)
                        let playTime = ScoreEncodingUtils.formatTime(playerBestTime)
                        Text(playTime)
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)

                        Text(NSLocalizedString("PLAY_TIME_LABEL", comment: "Player Card - Play Time Label"))
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.cyan.opacity(0.7))
                            .tracking(2)

                        // 랭킹과 킬 수 (시간 다음으로 중요)
                        HStack(spacing: 20) {
                            // 랭킹
                            if let playerRank = gameKitManager.playerRank {
                                VStack(spacing: 4) {
                                    Text("#\(playerRank)")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundColor(.yellow)
                                    Text(NSLocalizedString("RANK_LABEL", comment: "Player Card - Rank Label"))
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                        .foregroundColor(.yellow.opacity(0.7))
                                }
                            }

                            // 킬 수
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red.opacity(0.8))
                                        .font(.system(size: 14))
                                    Text("\(playerBestKills)")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                Text(NSLocalizedString("KILLS_LABEL", comment: "Player Card - Kills Label"))
                                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .padding(.top, 8)
                    }
                } else {
                    // 로그인 안 된 경우 - 로그인 메시지 표시
                    LoginPromptCard()
                }
            }
            .padding()
        }
    }
}

#Preview {
    PlayerCard()
}
