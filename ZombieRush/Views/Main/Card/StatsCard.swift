import SwiftUI

// MARK: - Stats Card
struct StatsCard: View {
    @Environment(AppRouter.self) var router
    @Environment(StatsStateManager.self) var statsStateManager
    @Environment(UserStateManager.self) var userStateManager
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            
            router.navigate(to: .myInfo(category: .stats))
        }) {
            ZStack {
                CardBackground()
                
                VStack(spacing: 8) {
                    // 타이틀
                    // 남은 포인트 표시
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.dsCoin)
                            .font(.system(size: 10))
                        
                        Text("남은 포인트: \(userStateManager.remainingPoints)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // 스텟 그리드 (3x2)
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        // 첫 번째 행 (3개)
                        StatMiniCard(
                            icon: "heart.fill",
                            label: "HP 회복",
                            value: statsStateManager.currentStats?.hpRecovery ?? 0,
                            color: .red
                        )
                        
                        StatMiniCard(
                            icon: "figure.run",
                            label: "이동속도",
                            value: statsStateManager.currentStats?.moveSpeed ?? 0,
                            color: .green
                        )
                        
                        StatMiniCard(
                            icon: "bolt.fill",
                            label: "에너지 회복",
                            value: statsStateManager.currentStats?.energyRecovery ?? 0,
                            color: .blue
                        )
                        
                        // 두 번째 행 (2개)
                        StatMiniCard(
                            icon: "target",
                            label: "공격속도",
                            value: statsStateManager.currentStats?.attackSpeed ?? 0,
                            color: .yellow
                        )
                        
                        StatMiniCard(
                            icon: "building.columns",
                            label: "토템",
                            value: statsStateManager.currentStats?.totemCount ?? 0,
                            color: .orange
                        )
                        
                        // 빈 공간 (3x2 그리드를 맞추기 위해)
                        StatMiniCard(
                            icon: "sparkles",
                            label: "네모의 응원",
                            value: statsStateManager.currentStats?.totemCount ?? 0,
                            color: .orange
                        )
                    }
                }
                .padding()
            }
            .buttonStyle(.plain) // 버튼 스타일 제거
        }
    }
}
