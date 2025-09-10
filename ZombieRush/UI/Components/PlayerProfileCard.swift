import SwiftUI
import GameKit

// MARK: - Player Profile Card Component
struct PlayerProfileCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            // 프로필 섹션
            profileSection
            
            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            // 전체 랭킹 섹션 (인증된 사용자만)
            if gameKitManager.isAuthenticated {
                rankSection
            }
            */

            // 임시로 랭킹 섹션 숨김
            // rankSection
            
            // 기록 또는 로그인 안내 섹션
            contentSection
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
    
    // MARK: - Profile Section
    private var profileSection: some View {
        HStack(spacing: 20) {
            
            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            // 프로필 이미지 (작게 만듦)
            Group {
                if let playerPhoto = gameKitManager.playerPhoto {
                    Image(uiImage: playerPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: gameKitManager.isAuthenticated ? "person.crop.circle.fill" : "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 50, height: 50)
            */

            // 임시 플레이스홀더
            Group {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
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
            .shadow(color: Color.cyan, radius: 5, x: 0, y: 0)
            
            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            // 닉네임 (프로필 우측에 위치)
            VStack(alignment: .leading, spacing: 2) {
                Text(gameKitManager.playerDisplayName)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)

                Text(gameKitManager.isAuthenticated ? NSLocalizedString("PROFILE_GAME_CENTER", comment: "Game Center label") : NSLocalizedString("PROFILE_GUEST_MODE", comment: "Guest mode label"))
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            */

            // 임시 닉네임 표시
            VStack(alignment: .leading, spacing: 2) {
                Text("Player")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)

                Text("Guest")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
                        
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        HStack {
            Spacer()
            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            if gameKitManager.isAuthenticated {
                authenticatedContent
            } else {
                guestContent
            }
            */

            // 임시로 게스트 콘텐츠 표시
            guestContent
            Spacer()
        }
        .padding(.bottom, 15)
    }
    
    // MARK: - Rank Section
    private var rankSection: some View {
        HStack(spacing: 20) {
            Text(NSLocalizedString("PROFILE_GLOBAL_RANK", comment: "Global rank label"))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))

            // TODO: GameKitManager 리팩토링 후 재활성화
            /*
            Group {
                if let rank = gameKitManager.playerRank {
                    Text("#\(rank)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(rankColor(for: rank))
                        .shadow(color: rankColor(for: rank), radius: 3, x: 0, y: 0)
                } else {
                    Text("--")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            */

            // 임시 랭크 표시
            Group {
                Text("#--")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: .white.opacity(0.3), radius: 3, x: 0, y: 0)
            }
        }
        .padding(.vertical, 5)
        // TODO: GameKitManager 리팩토링 후 재활성화
        /*
        .task {
            // 랭킹 정보 로드
            await loadPlayerRank()
        }
        */
    }
    
    // MARK: - Rank Color Helper
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .white
        case 3: return .orange
        default: return .gray 
        }
    }
    
    // MARK: - Load Player Rank
    private func loadPlayerRank() async {
        
    }
    
    // MARK: - Open iPhone Settings
    private func openGameCenterSettings() {
        // iPhone 설정 앱 열기
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Authenticated User Content
    private var authenticatedContent: some View {
        HStack {
            Spacer()

            // 글로벌 랭킹 정보 표시
            VStack(spacing: 8) {
                Text(NSLocalizedString("PROFILE_GLOBAL_RANK", comment: "Global rank label"))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)

                if let rank = gameKitManager.playerRank {
                    Text("#\(rank)")
                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 3, x: 0, y: 0)
                } else {
                    Text("-")
                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                        .foregroundColor(.gray)
                }

                Text("RANKING")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.cyan.opacity(0.7))
                    .tracking(1)
            }

            Spacer()

            // 플레이어 이름 표시
            VStack(spacing: 8) {
                Text("PLAYER")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white)

                Text(gameKitManager.playerDisplayName)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                    .frame(maxWidth: 120)

                Text("NAME")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.7))
                    .tracking(1)
            }

            Spacer()
        }
    }
    
    // MARK: - Guest User Content
    private var guestContent: some View {
        VStack(spacing: 15) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.cyan.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("PROFILE_SIGN_IN_PROMPT", comment: "Sign in prompt"))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                Text(NSLocalizedString("PROFILE_SIGN_IN_BENEFIT", comment: "Sign in benefit"))
                    .font(.system(size: 10, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            // iPhone 설정 앱으로 이동하는 버튼
            Button(action: {
                openGameCenterSettings()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                        .font(.system(size: 12, weight: .medium))
                    
                    Text(NSLocalizedString("PROFILE_OPEN_SETTINGS", comment: "Open settings button"))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cyan.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.cyan, lineWidth: 1)
                        )
                )
            }
            // iPhone 설정에서 Game Center 로그인 안내
            Text(NSLocalizedString("PROFILE_SETTINGS_PATH", comment: "Settings path guide"))
                .font(.system(size: 12, weight: .light, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - Preview
#Preview {
    PlayerProfileCard()
        .environment(GameKitManager())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
