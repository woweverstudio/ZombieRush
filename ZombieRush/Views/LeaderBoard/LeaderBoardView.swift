import SwiftUI
import GameKit

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @Environment(AppRouter.self) var router

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 0) {
                // 헤더
                headerSection
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            IconButton(iconName: "chevron.left", style: .white) {
                router.quitToMain()
            }

            Spacer()
            HStack {
                Text(DateUtils.getCurrentWeekString())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 2, x: 0, y: 0)
                
                Text(TextConstants.Leaderboard.title)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 2, x: 0, y: 0)
            }
            

            Spacer()
            
            IconButton(iconName: "chevron.left", style: .white) {
                router.quitToMain()
            }
            .hidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}


// MARK: - Preview
#Preview {
    LeaderBoardView()
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
