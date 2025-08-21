import SwiftUI

struct GameOverView: View {
    let playTime: TimeInterval
    let score: Int
    let wave: Int
    let onRestart: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            cyberpunkBackground
            
            // 격자 패턴
            gridPattern
            
            // 컨텐츠
            VStack {
                // 게임 오버 타이틀
                VStack(spacing: 4) {
                    SectionTitle("GAME", style: .magenta, size: 28)
                    SectionTitle("OVER", style: .cyan, size: 36)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                HStack {
                    // 좌측 상단 정보 라벨들 (랜드스케이프용 컴팩트)
                    VStack(alignment: .leading, spacing: 12) {
                        infoLabel(title: "TIME", value: formatTime(playTime))
                        infoLabel(title: "KILLS", value: "\(score)")
                        infoLabel(title: "WAVE", value: "\(wave)")
                    }
                    .padding(.leading, 80)
                    
                    Spacer()
                }
                
                Spacer()
                
                // 하단 버튼들
                HStack(spacing: 60) {
                    // 그만하기 버튼
                    NeonButton("QUIT", style: .magenta, width: 140, height: 50) {
                        onQuit()
                    }
                    
                    // 다시하기 버튼
                    NeonButton("RESTART", style: .cyan, width: 140, height: 50) {
                        onRestart()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Components
    
    private var cyberpunkBackground: some View {
        ZStack {
            // 메인 그라데이션 배경
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color(red: 0.05, green: 0.0, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 네온 오버레이
            RadialGradient(
                colors: [
                    Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.2),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
        }
    }
    
    private var gridPattern: some View {
        Canvas { context, size in
            let path = Path { path in
                // 수직 라인들
                let verticalCount = 8
                let verticalSpacing = size.width / CGFloat(verticalCount)
                
                for i in 1..<verticalCount {
                    let x = CGFloat(i) * verticalSpacing
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                
                // 수평 라인들
                let horizontalCount = 6
                let horizontalSpacing = size.height / CGFloat(horizontalCount)
                
                for i in 1..<horizontalCount {
                    let y = CGFloat(i) * horizontalSpacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            
            context.stroke(
                path,
                with: .color(Color(red: 0.0, green: 0.6, blue: 1.0).opacity(0.3)),
                lineWidth: 1
            )
        }
    }
    
    private func infoLabel(title: String, value: String) -> some View {
        HStack {
            Text("\(title): \(value)")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 8, x: 0, y: 0)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.0, green: 0.8, blue: 1.0), lineWidth: 2)
                                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 12, x: 0, y: 0)
                        )
                )
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.5), radius: 15, x: 0, y: 0)
            
            Spacer()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    GameOverView(
        playTime: 125.5,
        score: 42,
        wave: 5,
        onRestart: {},
        onQuit: {}
    )
}
