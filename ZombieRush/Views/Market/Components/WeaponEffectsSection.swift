import SwiftUI

// MARK: - Weapon Effects Section Component
struct WeaponEffectsSection: View {
    let item: MarketItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("무기 효과")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            VStack(spacing: 6) {
                if item.attackSpeedBonus != 1.0 {
                    let speedPercent = Int((item.attackSpeedBonus - 1.0) * 100)
                    EffectRow(icon: "speedometer", label: "공격 속도", value: speedPercent >= 0 ? "+\(speedPercent)%" : "\(speedPercent)%", color: .cyan)
                }
                if item.bulletCountBonus > 0 {
                    EffectRow(icon: "circle.grid.2x2.fill", label: "총알 개수", value: "+\(item.bulletCountBonus)", color: .orange)
                }
                if item.penetrationBonus > 0 {
                    EffectRow(icon: "arrow.right.circle.fill", label: "관통 수", value: "+\(item.penetrationBonus)", color: .purple)
                }
            }
        }
        .opacity(item.attackSpeedBonus != 1.0 || item.bulletCountBonus > 0 || item.penetrationBonus > 0 ? 1.0 : 0.0)
    }
}
