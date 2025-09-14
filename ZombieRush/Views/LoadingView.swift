import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @Environment(AppRouter.self) var router

    @State private var progress: Double = 0.0
    @State private var versionManager = VersionManager.shared

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 30) {
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
                    Text(getLoadingText())
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startLoadingProcess()
        }
        .fullScreenCover(isPresented: .constant(versionManager.shouldForceUpdate)) {
            // 강제 업데이트 화면 (닫을 수 없음)
            ForceUpdateView()
        }
    }

    private func getLoadingText() -> String {
        // 버전 체크가 완료되지 않았으면 버전 체크중 표시
        if !versionManager.hasCheckedVersion {
            return TextConstants.Loading.checkingVersion
        }

        // GameKit 로딩 상태 확인
        if gameKitManager.isLoading {
            return TextConstants.Loading.loadingData
        } else {
            return TextConstants.Loading.readyToPlay
        }
    }

    private func startLoadingProcess() {
        // 1. 먼저 버전 체크 수행
        Task {
            await versionManager.checkAppVersion()

            // 2. 버전 체크 완료 후 처리
            if versionManager.shouldForceUpdate {
                // 업데이트가 필요하면 여기서 끝남 (ForceUpdateView가 표시됨)
                return
            }

        // 3. 업데이트가 필요 없으면 GameKit 로딩 진행
        await proceedWithGameKitLoading()
        }
    }

    private func proceedWithGameKitLoading() async {
        // GameKit 뷰 컨트롤러 처리 설정
        setupGameKitCallbacks()

        // GameKit 데이터 로딩 시작
        gameKitManager.loadInitialData {
            // 데이터 로드 완료

            // 데이터 로딩 완료 후 프로그레스 바 채우기
            withAnimation(.easeInOut(duration: 0.5)) {
                self.progress = 1.0
            }

            // 프로그레스 바 애니메이션 완료 후 메인메뉴로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if router.currentRoute == .loading {
                    self.router.navigate(to: .mainMenu)
                }
            }
        }
    }

    private func setupGameKitCallbacks() {
        // 뷰 컨트롤러 표시 클로저 설정
        gameKitManager.presentViewController = { viewController in
            // 현재 표시된 뷰 컨트롤러 찾기
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(viewController, animated: true)
            }
        }

        // 뷰 컨트롤러 닫기 클로저 설정
        gameKitManager.dismissViewController = {
            // 현재 표시된 뷰 컨트롤러 닫기
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: true)
            }
        }

        // 인증 완료 이벤트 클로저 설정
        gameKitManager.onAuthenticationCompleted = {
            // 필요한 경우 추가 로직 수행 가능
        }
    }
}

// MARK: - Preview
#Preview {
    LoadingView()
        .environment(GameKitManager())
        .environment(AppRouter())
}
