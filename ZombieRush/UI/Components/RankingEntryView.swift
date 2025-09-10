import SwiftUI
import GameKit

struct RankingEntryView: View {
    @Environment(GameKitManager.self) var gameKitManager
    let entry: GKLeaderboard.Entry
    let rank: Int

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color.orange.opacity(0.8)
        default: return .white
        }
    }

    private var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // 순위
            Text(rankIcon)
                .font(.system(size: 18))
                .frame(width: 30, alignment: .center)

            // 프로필 이미지
            Group {
                if let image = gameKitManager.profileImages[entry.player.gamePlayerID] {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // 플레이어 정보 (시간 위주로 배치)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.player.displayName)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // 플레이 시간 (가장 크게 표시)
                let (timeInSeconds, _) = ScoreEncodingUtils.decodeScore(Int64(entry.score))
                let playTime = ScoreEncodingUtils.formatTime(timeInSeconds)
                Text(playTime)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(rankColor)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rankColor.opacity(0.1))
        )
    }
}
