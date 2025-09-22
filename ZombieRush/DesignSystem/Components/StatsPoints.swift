import SwiftUI

// MARK: - Stats Point Icon Sizes
enum StatsPointIconSize {
    case small
    case medium
    case large
    
    var frame: CGFloat {
        switch self {
        case .small:
            return 16
        case .medium:
            return 24
        case .large:
            return 44
        }
    }
}

// MARK: - Stats Point Icon Component
struct StatsPointIcon: View {
    let size: StatsPointIconSize

    init(size: StatsPointIconSize = .medium) {
        self.size = size
    }

    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color.cyan)
            .frame(width: size.frame, height: size.frame)
    }
}

// MARK: - Stats Point Badge Component (잔여 스텟포인트 표시)
struct StatsPointBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 6) {
            StatsPointIcon(size: .medium)
            Text("\(userStateManager.remainingPoints)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color.cyan)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stats Point Cost Component (비용 표시)
struct StatsPointCost: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            StatsPointIcon(size: .small)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.cyan)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 아이콘 크기별 표시
        HStack(spacing: 16) {
            VStack {
                StatsPointIcon(size: .small)
                Text("Small").font(.caption)
            }
            VStack {
                StatsPointIcon(size: .medium)
                Text("Medium").font(.caption)
            }
            VStack {
                StatsPointIcon(size: .large)
                Text("Large").font(.caption)
            }
        }

        // 뱃지 표시 (실제 잔여 포인트 표시)
        StatsPointBadge()

        // 비용 표시
        HStack(spacing: 16) {
            StatsPointCost(count: 1)
            StatsPointCost(count: 5)
            StatsPointCost(count: 10)
        }
    }
    .padding()
    .background(Color.black)
}
