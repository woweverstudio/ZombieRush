import SwiftUI
import GameKit

struct HallOfFameCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router

    var body: some View {
        ZStack {
            // 카드 배경
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.yellow.opacity(0.2), radius: 10, x: 0, y: 5)

            VStack(spacing: 12) {
                if gameKitManager.isAuthenticated {
                    // 로그인된 경우 - 명예의 전당 표시
                    // 타이틀
                    HStack {
                        Text("🏆")
                            .font(.system(size: 24))
                        Text(NSLocalizedString("HALL_OF_FAME_TITLE", comment: "Hall of Fame Card Title"))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                        Text("🏆")
                            .font(.system(size: 24))
                    }
                    
                    // 주차 정보
                    Text(DateUtils.getCurrentWeekString())
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.8))

                    // Top 3 플레이어 목록
                    VStack {
                        // 실제 entries 표시
                        ForEach(0..<gameKitManager.topThreeEntries.count, id: \.self) { index in
                            let entry = gameKitManager.topThreeEntries[index]
                            RankingEntryView(entry: entry, rank: index + 1)
                        }

                        // 부족한 만큼 스켈레톤 표시
                        ForEach(0..<max(0, 3 - gameKitManager.topThreeEntries.count), id: \.self) { index in
                            let skeletonRank = gameKitManager.topThreeEntries.count + index + 1
                            let skeletonEntry = GameKitManager.SkeletonEntry(
                                rank: skeletonRank,
                                message: TextConstants.GameCenter.skeletonMessage
                            )
                            RankingEntryView(entry: skeletonEntry, rank: skeletonRank)
                        }
                    }
                } else {
                    // 로그인 안 된 경우 - 로그인 메시지
                    VStack(spacing: 30) {
                        HStack {
                            Text("🏆")
                                .font(.system(size: 24))
                            Text(NSLocalizedString("HALL_OF_FAME_TITLE", comment: "Hall of Fame Card Title"))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            Text("🏆")
                                .font(.system(size: 24))
                        }
                        
                        // 주차 정보
                        Text(DateUtils.getCurrentWeekString())
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.yellow.opacity(0.8))
                        
                        Text(NSLocalizedString("LOGIN_PROMPT_HALL_OF_FAME", comment: "Login prompt for Hall of Fame Card"))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                        
                        Button(action: {
                            openGameCenterSettings()
                        }) {
                            Text(NSLocalizedString("PROFILE_SETTINGS_PATH", comment: "Player Profile Card"))
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
                }
            }
            .padding()
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
