import SwiftUI

// MARK: - Skin Effects Section Component
struct SkinEffectsSection: View {
    let item: MarketItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("스킨 효과")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            VStack(spacing: 6) {
                if item.healthBonus > 0 {
                    EffectRow(icon: "heart.fill", label: "체력 증가", value: "+\(item.healthBonus)", color: .red)
                }
                if item.ammoBonus > 0 {
                    EffectRow(icon: "circle.grid.2x2.fill", label: "탄약 증가", value: "+\(item.ammoBonus)", color: .yellow)
                }
                if item.speedBonus > 0 {
                    EffectRow(icon: "speedometer", label: "스피드 증가", value: "+\(item.speedBonus)", color: .green)
                }
            }
        }
        .opacity(item.healthBonus > 0 || item.ammoBonus > 0 || item.speedBonus > 0 ? 1.0 : 0.0)
    }
}
