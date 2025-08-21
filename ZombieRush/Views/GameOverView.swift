import SwiftUI

struct GameOverView: View {
    let playTime: TimeInterval
    let score: Int
    let wave: Int
    let isNewRecord: Bool
    let onRestart: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 기존 사이버펑크 배경 이미지 사용
                CyberpunkBackground(opacity: 0.5)
                
                VStack(spacing: 0) {                    
                    VStack {                        
                        if isNewRecord {
                            SectionTitle("NEW RECORD", style: .yellow, size: 32)
                        } else {
                            SectionTitle("Game Over", style: .cyan, size: 32)
                        }                             
                    }
                    .frame(height: geometry.size.height * 0.15)
                    
                    // 중단: 두 개의 블록 (화면의 55%)                                   
                    HStack(spacing: 20) {
                        // 좌측: Game Data 블록
                        gameDataBlock
                        
                        // 우측: Rank 블록
                        rankBlock
                    }
                    .padding(8)  // 패딩을 프레임 안으로 이동
                    .frame(height: geometry.size.height * 0.55)
                    
                    // 하단: 버튼들 (화면의 33%)
                    VStack {                                            
                        HStack(spacing: 20) {
                            // Quit 버튼 (화면 절반 너비)
                            NeonButton("QUIT", style: .cyan, width: nil, height: 50) {
                                onQuit()
                            }                            
                            
                            // Retry 버튼 (화면 절반 너비)
                            NeonButton("RETRY", style: .magenta, width: nil, height: 50) {
                                onRestart()
                            }                            
                        }                        
                    }
                    .frame(height: geometry.size.height * 0.2)
                }
            }
        }
    }
    
    // MARK: - Components
    
    // 좌측: Game Data 블록 (이미지 스타일)
    private var gameDataBlock: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                // TIME 섹션
                VStack {
                    SectionTitle("TIME", style: .cyan, size: 24)
                    
                    Text(formatTime(playTime))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 15, x: 0, y: 0)
                }

                Spacer()
                
                // ZOMBIES 섹션
                VStack {
                    SectionTitle("KILL", style: .cyan, size: 24)
                    
                    Text("\(score)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 15, x: 0, y: 0)
                }

                Spacer()            
            }
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 0.0, green: 0.8, blue: 1.0), lineWidth: 3)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 10, x: 0, y: 0)
                )
        )
        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3), radius: 20, x: 0, y: 0)
    }
    
    // 우측: Rank 블록 (실제 개인 랭크 데이터)
    private var rankBlock: some View {
        VStack {
            Spacer()
            
            // 랭크 리스트 타이틀
            SectionTitle("My Records Top 10", style: .magenta, size: 20)
                .padding(.vertical, 10)
            
            // 개인 랭크 리스트 (ScrollView로 10개 표시)
            ScrollView {
                LazyVStack(spacing: 8) {
                    let records = GameStateManager.shared.getPersonalRecords()
                    
                    if records.isEmpty {
                        // 기록이 없을 때
                        Text("No records yet")
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        // 기록이 있을 때
                        ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                            rankRow(
                                rank: "\(index + 1)",
                                time: record.formattedTime,
                                zombies: "\(record.zombieKills)"
                            )
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 1.0, green: 0.0, blue: 1.0), lineWidth: 3)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0), radius: 10, x: 0, y: 0)
                )
        )
        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.3), radius: 20, x: 0, y: 0)
    }
    

    
    // 랭크 행
    private func rankRow(rank: String, time: String, zombies: String) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.title3.bold().monospaced())
                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 1.0))
                .frame(width: 40, alignment: .leading)
            
            Text(time)
                .font(.title3.bold().monospaced())
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(zombies)")
                .font(.title3.bold().monospaced())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 15)
    }

    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    GameOverView(
        playTime: 125,
        score: 42,
        wave: 5,
        isNewRecord: false,
        onRestart: {},
        onQuit: {}
    )
}
