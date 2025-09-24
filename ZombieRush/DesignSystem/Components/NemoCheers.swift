import SwiftUI

// MARK: - Cheer Buff Icon Sizes
enum CheerBuffIconSize {
    case small   // 12pt
    case medium  // 16pt
    case large   // 24pt

    var iconSize: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 24
        case .large:
            return 44
        }
    }
}

// MARK: - Cheer Buff Icon Component
struct CheerBuffIcon: View {
    let size: CheerBuffIconSize

    init(size: CheerBuffIconSize = .medium) {
        self.size = size
    }

    var body: some View {
        Image(systemName: "medal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size.iconSize, height: size.iconSize)
            .foregroundColor(Color.dsSuccess)
    }
}

// MARK: - Cheer Buff Card Component (StatMiniCard 스타일)
struct CheerBuffCard: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                // 아이콘 (상단)
                Image(systemName: "medal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(isActive ? Color.dsSuccess : Color.dsTextDisabled)

                // 이름 (중앙)
                Text("네모의 응원")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.dsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // 상태 (하단)
                Text(isActive ? "ON" : "OFF")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isActive ? Color.dsSuccess : Color.dsTextDisabled)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.dsCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isActive ? Color.dsSuccess.opacity(0.3) : Color.dsTextDisabled.opacity(0.3), lineWidth: 0.5)
                    )
            )

            // 활성화된 경우 화려한 효과 추가
            if isActive {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.dsSuccess.opacity(0.5), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.dsSuccess.opacity(0.08))
                    )
                    .blur(radius: 0.3)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Cheer Buff Status Component (간단한 상태 표시)
struct CheerBuffStatus: View {
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "medal.fill")
                .font(.system(size: 14))
                .foregroundColor(userRepository.currentUser?.isCheerBuffActive ?? false ? Color.dsSuccess : Color.dsTextDisabled)

            Text(userRepository.currentUser?.isCheerBuffActive ?? false ? "네모의 응원 ON" : "네모의 응원 OFF")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(userRepository.currentUser?.isCheerBuffActive ?? false ? Color.dsSuccess : Color.dsTextDisabled)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 아이콘 크기별 표시
        HStack(spacing: 16) {
            VStack {
                CheerBuffIcon(size: .small)
                Text("Small").font(.caption)
            }
            VStack {
                CheerBuffIcon(size: .medium)
                Text("Medium").font(.caption)
            }
            VStack {
                CheerBuffIcon(size: .large)
                Text("Large").font(.caption)
            }
        }

        // 카드 표시 (활성화/비활성화)
        HStack(spacing: 16) {
            CheerBuffCard(isActive: true)
            CheerBuffCard(isActive: false)
        }

        // 상태 표시
        VStack(spacing: 8) {
            CheerBuffStatus()
        }
    }
    .padding()
    .background(Color.black)
}
