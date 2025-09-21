import SwiftUI

// MARK: - Header Badge Types
enum HeaderBadgeType {
    case statsPoints
    case nemoFruits

    @ViewBuilder
    var view: some View {
        switch self {
        case .statsPoints:
            StatsPointBadge()
        case .nemoFruits:
            NemoFruitsBadge()
        }
    }
}

// MARK: - Header Component
struct Header: View {
    let title: String
    let showBackButton: Bool
    let badges: [HeaderBadgeType]
    let onBack: (() -> Void)?

    init(
        title: String,
        showBackButton: Bool = true,
        badges: [HeaderBadgeType] = [],
        onBack: (() -> Void)? = nil
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.badges = badges
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            // 가운데: 타이틀 (항상 중앙에 고정)
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
                .shadow(color: Color.cyan, radius: 10, x: 0, y: 0)

            // 좌측 + 우측 요소들
            HStack {
                // 좌측: 뒤로가기 버튼
                if showBackButton {
                    IconButton(iconName: "chevron.left", style: .white) {
                        onBack?()
                    }
                }

                Spacer()

                // 우측: 배지들
                HStack(spacing: 12) {
                    ForEach(badges.indices, id: \.self) { index in
                        badges[index].view
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Badge Components (Header에서 사용)
struct StatsPointBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundColor(Color.dsCoin)
                .font(.system(size: 20))
            Text("\(userStateManager.remainingPoints)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.dsCoin)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dsOverlay)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.neonYellow.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct NemoFruitsBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "diamond.fill")
                .foregroundColor(Color.cyan)
                .font(.system(size: 20))
            Text("\(userStateManager.nemoFruits)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.cyan)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dsOverlay)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 배지가 있는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "내 정보", badges: [.statsPoints, .nemoFruits])

        // 배지가 없는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "마켓", badges: [.nemoFruits])

        // 배지와 뒤로가기 버튼이 없는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "설정", showBackButton: false)

        // 비교를 위한 기존 배지 없는 경우
        Header(title: "리더보드")
    }
    .background(Color.dsBackground)
}
