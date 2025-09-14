import SwiftUI
import GameKit

struct HallOfFameCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router

    var body: some View {
        ZStack {
            cardBackground
            cardContent
        }
    }

    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.1))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .shadow(color: Color.yellow.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 12) {
            if gameKitManager.isAuthenticated {
                authenticatedContent
            } else {
                unauthenticatedContent
            }
        }
        .padding()
    }

    // MARK: - Authenticated Content
    private var authenticatedContent: some View {
        Group {
            // 타이틀
            hallOfFameTitle

            // 주차 정보
            Text(DateUtils.getCurrentWeekString())
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.yellow.opacity(0.8))
                .padding(.bottom)

            // Top 3 플레이어 목록
            topThreeRankings
        }
    }

    // MARK: - Unauthenticated Content
    private var unauthenticatedContent: some View {
        VStack(spacing: 30) {
            // 타이틀
            hallOfFameTitle

            // 주차 정보
            Text(DateUtils.getCurrentWeekString())
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.yellow.opacity(0.8))

            // 로그인 프롬프트
            Text(TextConstants.HallOfFame.loginPrompt)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // 설정 버튼
            settingsButton
        }
    }

    // MARK: - Common Components
    private var hallOfFameTitle: some View {
        HStack {
            Text("🏆")
                .font(.system(size: 24))
            Text(TextConstants.HallOfFame.title)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
            Text("🏆")
                .font(.system(size: 24))
        }
    }

    private var topThreeRankings: some View {
        VStack {
            // 실제 entries 표시
            realEntriesView

            // 스켈레톤 entries 표시
            skeletonEntriesView
        }
    }

    private var realEntriesView: some View {
        let entries = gameKitManager.topThreeEntries
        return ForEach(entries.indices, id: \.self) { index in
            RankingEntryView(entry: entries[index], rank: index + 1)
        }
    }

    private var skeletonEntriesView: some View {
        let skeletonCount = max(0, 3 - gameKitManager.topThreeEntries.count)
        let startRank = gameKitManager.topThreeEntries.count + 1
        let skeletonMessage = TextConstants.Leaderboard.skeletonMessage

        return ForEach(0..<skeletonCount, id: \.self) { index in
            let skeletonEntry = GameKitManager.SkeletonEntry(
                rank: startRank + index,
                message: skeletonMessage
            )
            RankingEntryView(entry: skeletonEntry, rank: startRank + index)
        }
    }

    private var settingsButton: some View {
        Button(action: {
            openGameCenterSettings()
        }) {
            Text(TextConstants.Profile.settingsPath)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Open iPhone Settings
    private func openGameCenterSettings() {
        // iPhone 설정 앱 열기
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

#Preview {
    HallOfFameCard()
}
