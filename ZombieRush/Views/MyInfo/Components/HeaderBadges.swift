import SwiftUI

// MARK: - 헤더 배지 컴포넌트들
struct StatsPointBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 20))
            Text("\(userStateManager.remainingPoints)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct NemoFruitsBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "diamond.fill")
                .foregroundColor(.cyan)
                .font(.system(size: 20))
            Text("\(userStateManager.nemoFruits)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
