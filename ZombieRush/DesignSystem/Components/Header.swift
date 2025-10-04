import SwiftUI

// MARK: - Header Badge Types
enum HeaderBadgeType {
    case statsPoints
    case gem

    @ViewBuilder
    var view: some View {
        switch self {
        case .statsPoints:
            StatsPointBadge()
        case .gem:
            GemBadge()
        }
    }
}

// MARK: - Header Component
struct Header: View {
    let title: String
    let showBackButton: Bool
    let badges: [HeaderBadgeType]
    let onBack: (() -> Void)?
    let onBadgeTap: ((HeaderBadgeType) -> Void)?

    init(
        title: String,
        showBackButton: Bool = true,
        badges: [HeaderBadgeType] = [],
        onBack: (() -> Void)? = nil,
        onBadgeTap: ((HeaderBadgeType) -> Void)? = nil
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.badges = badges
        self.onBack = onBack
        self.onBadgeTap = onBadgeTap
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
                        Button(action: {
                            onBadgeTap?(badges[index])
                        }) {
                            badges[index].view
                        }
                        .buttonStyle(.plain) // 기본 버튼 스타일 제거
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}



// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 배지가 있는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "내 정보", badges: [.statsPoints, .gem])

        // 배지가 없는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "마켓", badges: [.gem])

        // 배지와 뒤로가기 버튼이 없는 경우 - 타이틀이 중앙에 고정됨
        Header(title: "설정", showBackButton: false)

        // 비교를 위한 기존 배지 없는 경우
        Header(title: "리더보드")
    }
    .background(Color.dsBackground)
}
