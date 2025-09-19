import SwiftUI

struct GameOverView: View {
    let playTime: Int
    let score: Int
    let success: Bool
    let onQuit: () -> Void

    @Environment(GameKitManager.self) var gameKitManager
    @Environment(AppRouter.self) var router


    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack {
                // 우측 상단 X 버튼
                HStack {
                    Spacer()
                    Button(action: {
                        DispatchQueue.global(qos: .userInteractive).async {
                            AudioManager.shared.playButtonSound()
                            HapticManager.shared.playButtonHaptic()
                        }
                        
                        router.quitToMain()                        
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GameOverView(
        playTime: 125,
        score: 42,
        success: true,
        onQuit: {}
    )
    .environment(GameKitManager())
    .environment(AppRouter())
    .preferredColorScheme(.dark)
}
