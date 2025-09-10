import SwiftUI
import GameKit

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 0) {
                // 헤더
                headerSection

                // 콘텐츠 영역
                if isLoading {
                    loadingView
                } else {
                    leaderboardContent
                }
            }
        }
        .onAppear {
            loadLeaderboardData()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            BackButton(style: .cyan) {
                router.goBack()
            }

            Spacer()

            Text(NSLocalizedString("LEADERBOARD_TITLE", comment: "Leaderboard screen title"))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.5), radius: 2, x: 0, y: 0)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.cyan)
            Text(NSLocalizedString("LOADING_DATA", comment: "Loading screen - Loading data text"))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.8))
                .padding(.top, 20)
            Spacer()
        }
    }

    // MARK: - Leaderboard Content
    private var leaderboardContent: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(gameKitManager.top100Entries.enumerated()), id: \.element.player.gamePlayerID) { index, entry in
                    LeaderboardEntryRow(
                        rank: index + 1,
                        entry: entry,
                        playerImage: gameKitManager.profileImages[entry.player.gamePlayerID]
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Data Loading
    private func loadLeaderboardData() {
        isLoading = true

        Task {
            await gameKitManager.loadTop100Leaderboard {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Leaderboard Entry Row
struct LeaderboardEntryRow: View {
    let rank: Int
    let entry: GKLeaderboard.Entry
    let playerImage: UIImage?

    var body: some View {
        HStack(spacing: 16) {
            // 랭킹 번호
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(rankColor(for: rank))
                .frame(width: 60, alignment: .center)

            // 프로필 이미지
            if let image = playerImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.cyan.opacity(0.5), lineWidth: 2))
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    )
            }

            // 플레이어 이름
            Text(entry.player.displayName)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 시간과 킬 수 (수평 배치)
            let (timeInSeconds, kills) = ScoreEncodingUtils.decodeGameCenterScore(entry.score)

            // 플레이 시간 (우선순위 1)
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
                Text(ScoreEncodingUtils.formatTime(timeInSeconds))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }

            // 킬 수 (우선순위 2)
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                Text("\(kills)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rankBorderColor(for: rank), lineWidth: rank <= 3 ? 2 : 1)
                )
        )
        .shadow(color: rankColor(for: rank).opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .white
        case 3: return .brown
        default: return .secondary
        }
    }

    private func rankBorderColor(for rank: Int) -> Color {
        rankColor(for: rank).opacity(0.5)
    }
}

// MARK: - Preview
#Preview {
    LeaderBoardView()
        .environment(GameKitManager())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
