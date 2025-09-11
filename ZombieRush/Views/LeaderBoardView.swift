import SwiftUI
import GameKit

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @State private var isLoading = true
    @State private var showingErrorMessage: Bool = false

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
        .task {
            do {
                try await loadLeaderboardData()
            } catch {
                //TODO: 데이터 조회 실패 시 어떻게 할 것인가 (ver 1.1.1)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            BackButton(style: .cyan) {
                router.goBack()
            }

            Spacer()
            HStack {
                Text(DateUtils.getCurrentWeekString())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 2, x: 0, y: 0)
                
                Text(NSLocalizedString("LEADERBOARD_TITLE", comment: "Leaderboard screen title"))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 2, x: 0, y: 0)
            }
            

            Spacer()
            
            BackButton(style: .cyan) {
                
            }
            .hidden()
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
                // 실제 데이터 표시
                ForEach(Array(gameKitManager.top100Entries.enumerated()), id: \.element.player.gamePlayerID) { index, entry in
                    LeaderboardEntryRow(
                        rank: index + 1,
                        entry: entry,
                        playerImage: gameKitManager.profileImages[entry.player.gamePlayerID]
                    )
                }

                // 부족한 만큼 placeholder 표시
                if gameKitManager.top100Entries.count < 100 {
                    ForEach((gameKitManager.top100Entries.count + 1)...100, id: \.self) { rank in
                        LeaderboardEntryRow(
                            rank: rank,
                            entry: nil,
                            playerImage: nil,
                            isPlaceholder: true
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Data Loading
    private func loadLeaderboardData() async throws {
        isLoading = true
        
        try await gameKitManager.loadTop100Leaderboard {
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
}

// MARK: - Leaderboard Entry Row
struct LeaderboardEntryRow: View {
    let rank: Int
    let entry: GKLeaderboard.Entry?
    let playerImage: UIImage?
    let isPlaceholder: Bool
    
    init(rank: Int, entry: GKLeaderboard.Entry?, playerImage: UIImage?, isPlaceholder: Bool = false) {
        self.rank = rank
        self.entry = entry
        self.playerImage = playerImage
        self.isPlaceholder = isPlaceholder
    }

    var body: some View {
        HStack(spacing: 16) {
            // 랭킹 번호
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(isPlaceholder ? .gray : rankColor(for: rank))
                .frame(width: 60, alignment: .center)

            // 프로필 이미지
            if isPlaceholder {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.circle")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 20))
                    )
            } else if let image = playerImage {
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

            // 플레이어 이름 또는 placeholder 메시지
            if isPlaceholder {
                Text(NSLocalizedString("SKELETON_MESSAGE", comment: "Leaderboard skeleton message"))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.7))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let entry = entry {
                Text(entry.player.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 시간과 킬 수 (수평 배치)
            if isPlaceholder {
                // placeholder일 때
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("-")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                }

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("-")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                }
            } else if let entry = entry {
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
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isPlaceholder ? Color.gray.opacity(0.1) : Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPlaceholder ? Color.gray.opacity(0.3) : rankBorderColor(for: rank), lineWidth: rank <= 3 && !isPlaceholder ? 2 : 1)
                )
        )
        .shadow(color: isPlaceholder ? Color.gray.opacity(0.1) : rankColor(for: rank).opacity(0.3), radius: 4, x: 0, y: 2)
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
