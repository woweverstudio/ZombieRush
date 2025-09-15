import SwiftUI

// MARK: - Market Item Small Card (좌측 그리드용)
struct MarketItemSmallCard: View {
    let item: MarketItem
    let isSelected: Bool
    let onTap: () -> Void

    // 계산된 속성들
    private var strokeColor: Color {
        if isSelected {
            return Color.cyan
        } else if item.isPurchased {
            return Color.green
        } else {
            return Color.white.opacity(0.3)
        }
    }

    private var shadowColor: Color {
        let baseColor = strokeColor
        let opacity: Double = isSelected ? 0.8 : 0.4
        return baseColor.opacity(opacity)
    }

    private var shadowRadius: CGFloat {
        return isSelected ? 8 : 4
    }

    private var strokeWidth: CGFloat {
        return isSelected ? 3 : 1
    }

    private var iconColor: Color {
        if item.isPurchased {
            return .green
        } else if isSelected {
            return .cyan
        } else {
            return .white
        }
    }

    private var textColor: Color {
        return isSelected ? .cyan : .white
    }

    private var backgroundFillColor: Color {
        return isSelected ? Color.cyan.opacity(0.1) : Color.black.opacity(0.2)
    }

    private var backgroundStrokeColor: Color {
        return isSelected ? Color.cyan.opacity(0.5) : Color.clear
    }

    var body: some View {
        VStack(spacing: 8) {
            // 아이콘 (1:1 비율)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.8))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(strokeColor, lineWidth: strokeWidth)
                    )
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)

                Image(systemName: item.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)

                if item.isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .offset(x: 28, y: -28)
                }
            }
            .frame(maxWidth: .infinity)

            // 아이템 이름
            Text(item.name)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
                .lineLimit(1)
                .truncationMode(.tail)

            // 가격 또는 보유 상태
            if item.isPurchased {
                Text("보유")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.2))
                    )
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "dollarsign")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                    Text("\(item.price)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.4))
                )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundFillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(backgroundStrokeColor, lineWidth: 1)
                )
        )
        .onTapGesture {
            // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            onTap()
        }
    }
}
