import SwiftUI

// MARK: - LeaderBoard View
struct LeaderBoardView: View {
    @StateObject private var router = AppRouter.shared
    @StateObject private var gameKitManager = GameKitManager.shared
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground(opacity: 0.5)
                .ignoresSafeArea()

            VStack {                             
                HStack {
                    // 뒤로가기 버튼
                    BackButton(style: .cyan) {
                        router.goBack()
                    }
                    
                    Spacer()
                    
                    // 타이틀
                    SectionTitle("LEADER BOARD", style: .cyan, size: 28)
                    
                    Spacer()
                    
                    // 균형을 위한 투명 버튼
                    BackButton(style: .cyan) {
                        // 아무 동작 안함
                    }
                    .opacity(0)
                }    
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // 중단: 두 개의 블록 (화면의 85%)
                HStack(spacing: 20) {
                    // 좌측: 내 프로필 블록
                    myProfileBlock
                    
                    // 우측: 글로벌 랭킹 블록
                    globalRankingBlock
                }                          
            }
            .padding()
        }
        
    }
    
    // MARK: - Components
    
    // 좌측: 내 프로필 블록
    private var myProfileBlock: some View {
        VStack {
            Spacer()
            
            // 내 프로필 정보
            VStack(spacing: 20) {
                // 프로필 사진 (GameKit에서 가져온 실제 사진 또는 기본 아이콘)
                Group {
                    if let playerPhoto = gameKitManager.playerPhoto {
                        Image(uiImage: playerPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        // 기본 프로필 아이콘
                        Image(systemName: gameKitManager.isAuthenticated ? "person.crop.circle.fill" : "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.cyan, radius: 10, x: 0, y: 0)
                
                // 닉네임 (GameKit에서 가져온 실제 닉네임)
                SectionTitle(gameKitManager.playerDisplayName, style: .cyan, size: 20)
                
                // 인증 상태에 따른 내용 표시
                if gameKitManager.isAuthenticated {
                    // 내 최고 기록 (인증된 사용자) - UserDefaults에서 실제 데이터 로드
                    VStack(spacing: 15) {
                        SectionTitle("My Best Record", style: .cyan, size: 16)
                        
                        // 개인 기록에서 최고 기록 가져오기
                        let personalRecords = GameStateManager.shared.getPersonalRecords()
                        let bestRecord = personalRecords.first
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("TIME:")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.cyan)
                                Spacer()
                                Text(bestRecord?.formattedTime ?? "00:00")
                                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("KILLS:")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.cyan)
                                Spacer()
                                Text("\(bestRecord?.zombieKills ?? 0)")
                                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                } else {
                    // Game Center 로그인 안내 (비인증 사용자)
                    VStack(spacing: 15) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.cyan.opacity(0.6))
                        
                        Text("Sign in to Game Center")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("to view your records")
                            .font(.system(size: 12, weight: .light, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        
                        // 인증 상태 표시
                        Text("Status: \(gameKitManager.authenticationStatus)")
                            .font(.system(size: 10, weight: .light, design: .monospaced))
                            .foregroundColor(Color.cyan.opacity(0.7))
                            .padding(.top, 5)
                        
                        // 재시도 버튼
                        Button(action: {
                            print("Manual GameKit authentication retry")
                            gameKitManager.retryAuthentication()
                        }) {
                            Text("Try Again")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.cyan.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.cyan, lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.cyan, lineWidth: 2)
                        .shadow(color: Color.cyan, radius: 8, x: 0, y: 0)
                )
        )
        .shadow(color: Color.cyan.opacity(0.3), radius: 15, x: 0, y: 0)
    }
    
    // 우측: 글로벌 랭킹 블록
    private var globalRankingBlock: some View {
        VStack {
            Spacer()
            
            // 글로벌 랭킹 타이틀
            SectionTitle("Global Ranking", style: .magenta, size: 18)
                .padding(.vertical, 10)
            
            // 랭킹 리스트
            ScrollView {
                LazyVStack(spacing: 8) {
                    // 하드코딩된 테스트 데이터
                    let testData = [
                        ("Player1", "06:45", "189"),
                        ("ZombieHunter", "06:12", "178"),
                        ("ProGamer", "05:58", "167"),
                        ("TestPlayer", "05:23", "156"),
                        ("Newbie123", "04:45", "134"),
                        ("GameMaster", "04:12", "125"),
                        ("CoolPlayer", "03:58", "118"),
                        ("FastRunner", "03:45", "112")
                    ]
                    
                    ForEach(Array(testData.enumerated()), id: \.offset) { index, data in
                        globalRankRow(
                            rank: index + 1,
                            nickname: data.0,
                            time: data.1,
                            kills: data.2,
                            isMe: data.0 == "TestPlayer"
                        )
                    }
                }
                .padding(.horizontal, 10)
            }            
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.magenta, lineWidth: 2)
                        .shadow(color: Color.magenta, radius: 8, x: 0, y: 0)
                )
        )
        .shadow(color: Color.magenta.opacity(0.3), radius: 15, x: 0, y: 0)
    }
    
    // 글로벌 랭킹 행
    private func globalRankRow(rank: Int, nickname: String, time: String, kills: String, isMe: Bool = false) -> some View {
        HStack(spacing: 10) {
            // 순위
            Text("#\(rank)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(rank <= 3 ? Color.yellow : Color.magenta)
                .frame(width: 30, alignment: .leading)
            
            // 프로필 사진 (작은 버전)
            Circle()
                .fill(
                    LinearGradient(
                        colors: isMe ? [Color.cyan, Color.blue] : [Color.magenta, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                )
            
            // 닉네임
            Text(nickname)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(isMe ? Color.cyan : .white)
                .lineLimit(1)
                .frame(maxWidth: 80, alignment: .leading)
            
            Spacer()
            
            // 시간
            Text(time)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
            
            // 킬수
            Text(kills)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            isMe ? 
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.cyan.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.cyan, lineWidth: 1)
                ) :
            nil
        )
    }
}

// MARK: - Preview
#Preview {
    LeaderBoardView()
}
