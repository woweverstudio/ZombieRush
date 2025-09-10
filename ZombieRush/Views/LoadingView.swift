import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    @State private var progress: Double = 0.0
    private let loadingDuration: Double = 2.0 // 2초 로딩

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 40) {
                Spacer()

                // 게임 타이틀 (로딩 화면용으로 크게)
                GameTitle(titleSize: 40, subtitleSize: 60)


                // 로딩 프로그레스 바
                VStack(spacing: 20) {
                    // 프로그레스 바
                    ZStack(alignment: .leading) {
                        // 배경 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)

                        // 진행 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.purple.opacity(0.8))
                            .frame(width: progress * 300, height: 8)
                    }
                    .frame(width: 300)

                    // 로딩 텍스트
                    Text("LOADING...")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startLoadingAnimation()
        }
    }

    private func startLoadingAnimation() {
        // 2초 동안 프로그레스를 0에서 1로 증가시키는 애니메이션
        withAnimation(.easeInOut(duration: loadingDuration)) {
            progress = 1.0
        }
    }
}

// MARK: - Preview
#Preview {
    LoadingView()
}
