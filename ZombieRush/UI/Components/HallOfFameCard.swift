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
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.8))

                    // Top 3 플레이어 목록
                    VStack {
                        ForEach(0..<min(3, gameKitManager.topThreeEntries.count), id: \.self) { index in
                            let entry = gameKitManager.topThreeEntries[index]
                            RankingEntryView(entry: entry, rank: index + 1)
                        }
                    }
                } else {
                    // 로그인 안 된 경우 - 로그인 메시지
                    VStack(spacing: 30) {
                        // 주차 정보
                        Text(DateUtils.getCurrentWeekString())
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.yellow.opacity(0.6))
                            .padding(.bottom, 4)

                        Image(systemName: "trophy.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.yellow.opacity(0.5))

                        Text(NSLocalizedString("LOGIN_PROMPT_HALL_OF_FAME", comment: "Login prompt for Hall of Fame Card"))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    HallOfFameCard()
}
