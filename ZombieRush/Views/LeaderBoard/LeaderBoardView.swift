import SwiftUI
import GameKit

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    @State private var isLoading = true
    @State private var showingErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    @State private var canRetry = true

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
                } else if showingErrorMessage {
                    errorView
                } else {
                    leaderboardContent
                }
            }
        }
        .task {
            await loadDataWithErrorHandling()
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
                
                Text(TextConstants.Leaderboard.title)
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
            Text(TextConstants.Loading.loadingData)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.8))
                .padding(.top, 20)
            Spacer()
        }
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.red.opacity(0.8))

                Text(TextConstants.Leaderboard.errorTitle)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Text(errorMessage.isEmpty ?
                     TextConstants.Leaderboard.errorMessage :
                     errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            if canRetry {
                Button(action: {
                    Task {
                        await retryLoadData()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                        Text(TextConstants.Leaderboard.retryButton)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding(.top, 10)
            }

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
    private func loadDataWithErrorHandling() async {
        do {
            try await loadLeaderboardData()
        } catch {
            handleError(error)
        }
    }

    private func loadLeaderboardData() async throws {
        isLoading = true
        showingErrorMessage = false
        errorMessage = ""
        canRetry = true

        try await gameKitManager.loadTop100Leaderboard {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    private func retryLoadData() async {
        await loadDataWithErrorHandling()
    }

    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.showingErrorMessage = true
            self.canRetry = true

            let nsError = error as NSError

            // GameKit 관련 에러 처리
            if nsError.domain == "GameKit" || nsError.domain == GKErrorDomain {
                switch nsError.code {
                case GKError.Code.notAuthenticated.rawValue:
                    self.errorMessage = TextConstants.Error.gameKitNotAuthenticated
                case GKError.Code.communicationsFailure.rawValue:
                    self.errorMessage = TextConstants.Error.gameKitNetworkError
                case 1001: // 커스텀 리더보드 찾기 실패 에러
                    self.errorMessage = TextConstants.Error.gameKitLeaderboardNotFound
                default:
                    self.errorMessage = TextConstants.Error.gameKitGeneric
                }
            } else {
                // 일반적인 네트워크 에러
                self.errorMessage = TextConstants.Error.genericNetwork
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
                        Text(TextConstants.Leaderboard.skeletonMessage)
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
                    Spacer()
                }
                .frame(width: 100)

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("-")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                    Spacer()
                }
                .frame(width: 80)
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
                    Spacer()
                }
                .frame(width: 100)

                // 킬 수 (우선순위 2)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    Text("\(kills)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.red)
                    Spacer()
                }
                .frame(width: 80)
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
