import SwiftUI
import GameKit

struct RankingEntryView: View {
    @Environment(GameKitManager.self) var gameKitManager
    let entry: Any
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
                if let realEntry = entry as? GKLeaderboard.Entry,
                   let image = gameKitManager.profileImages[realEntry.player.gamePlayerID] {
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
                if let realEntry = entry as? GKLeaderboard.Entry {
                    // 실제 플레이어 정보
                    Text(realEntry.player.displayName)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // 플레이 시간 (가장 크게 표시)
                    let (timeInSeconds, _) = ScoreEncodingUtils.decodeScore(Int64(realEntry.score))
                    let playTime = ScoreEncodingUtils.formatTime(timeInSeconds)
                    Text(playTime)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(rankColor)
                } else if let skeletonEntry = entry as? GameKitManager.SkeletonEntry {
                    // 스켈레톤 정보
                    Text(skeletonEntry.message)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
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
