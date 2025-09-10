import SwiftUI

struct GameOverView: View {
    let playTime: Int
    let score: Int
    let success: Bool
    let onQuit: () -> Void

    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router

    // 계산된 값들
    private var formattedPlayTime: String {
        let minutes = playTime / 60
        let seconds = playTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var currentScore: Int64 {
        return ScoreEncodingUtils.encodeScore(timeInSeconds: playTime, zombieKills: score)
    }

    private var isNewRecord: Bool {
        return gameKitManager.playerScore < currentScore
    }

    private var recordImprovement: String {
        // 현재 최고 기록 시간(초 단위)을 가져옴
        let currentBestTime = gameKitManager.playerScore > 0 ?
            ScoreEncodingUtils.decodeScore(gameKitManager.playerScore).timeInSeconds : 0

        let timeDifference = playTime - currentBestTime

        if currentBestTime == 0 {
            return "\(DateUtils.getCurrentWeekString())" + " " + "첫 기록!"
        }

        if timeDifference > 0 {
            let minutes = timeDifference / 60
            let seconds = timeDifference % 60
            return String(format: "최고 기록 대비: %02d:%02d 초과", minutes, seconds)
        } else if timeDifference < 0 {
            let minutes = abs(timeDifference) / 60
            let seconds = abs(timeDifference) % 60
            return String(format: "최고 기록 대비:%02d:%02d 부족", minutes, seconds)
        } else {
            return "동점"
        }
    }

    private var currentRank: Int? {
        return gameKitManager.playerRank
    }

    private var isInHallOfFame: Bool {
        return (currentRank ?? Int.max) <= 3
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack {
                // 우측 상단 X 버튼
                HStack {
                    Spacer()
                    Button(action: {
                        DispatchQueue.global(qos: .userInteractive).async {
                            AudioManager.shared.playButtonSound()
                            HapticManager.shared.playButtonHaptic()
                        }
                        gameKitManager.refreshData()
                        router.navigate(to: .mainMenu)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }

                Spacer()

                // 메인 콘텐츠
                mainContent

                Spacer()
            }
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            titleSection
            Spacer()
            gameStatsSection         
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 10) {
            mainTitleText
            subtitleText
        }
    }

    private var mainTitleText: some View {
        if isNewRecord {
            Text("🎉 신기록 달성! 🎉")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 5, x: 0, y: 0)
        } else {
            Text("게임 종료")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)
        }
    }

    private var subtitleText: some View {
        Text(recordImprovement)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))
    }

    // MARK: - Game Stats Section
    private var gameStatsSection: some View {
        HStack(spacing: 60) {
            // 플레이 시간
            VStack(spacing: 8) {
                Text("플레이 시간")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.cyan.opacity(0.8))
                Text(formattedPlayTime)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.3), radius: 2, x: 0, y: 0)
            }

            // 처치 수
            VStack(spacing: 8) {
                Text("처치 수")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.red.opacity(0.8))
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.3), radius: 2, x: 0, y: 0)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GameOverView(
        playTime: 125,
        score: 42,
        success: true,
        onQuit: {}
    )
    .environment(GameKitManager())
    .environment(AppRouter())
    .preferredColorScheme(.dark)
}
