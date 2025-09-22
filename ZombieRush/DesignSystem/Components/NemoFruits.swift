import SwiftUI

// MARK: - Nemo Fruit Icon Sizes
enum NemoFruitIconSize {
    case small   // 12pt
    case medium  // 16pt
    case large   // 24pt

    var fontSize: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 18
        case .large:
            return 24
        }
    }
}

// MARK: - Nemo Fruit Icon Component
struct NemoFruitIcon: View {
    let size: NemoFruitIconSize

    init(size: NemoFruitIconSize = .medium) {
        self.size = size
    }

    var body: some View {
        Image(systemName: "diamond.fill")
            .font(.system(size: size.fontSize))
            .foregroundColor(.yellow)
    }
}

// MARK: - Nemo Fruit Badge Component (잔여 네모열매 표시)
struct NemoFruitBadge: View {
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        HStack(spacing: 6) {
            NemoFruitIcon(size: .medium)
            Text("\(userStateManager.nemoFruits)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Nemo Fruit Cost Component (비용 표시)
struct NemoFruitCost: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            NemoFruitIcon(size: .small)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 아이콘 크기별 표시
        HStack(spacing: 16) {
            VStack {
                NemoFruitIcon(size: .small)
                Text("Small").font(.caption)
            }
            VStack {
                NemoFruitIcon(size: .medium)
                Text("Medium").font(.caption)
            }
            VStack {
                NemoFruitIcon(size: .large)
                Text("Large").font(.caption)
            }
        }

        // 뱃지 표시 (실제 잔여 개수 표시)
        NemoFruitBadge()

        // 비용 표시
        HStack(spacing: 16) {
            NemoFruitCost(count: 5)
            NemoFruitCost(count: 25)
            NemoFruitCost(count: 100)
        }
    }
    .padding()
    .background(Color.black)
}
