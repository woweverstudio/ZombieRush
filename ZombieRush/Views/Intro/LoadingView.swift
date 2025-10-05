import SwiftUI


// MARK: - Loading View

/// 로딩 단계 정의
enum LoadingStage: Int, CaseIterable {
    case versionCheck = 0
    case gameCenterAuth
    case dataLoading
    case completed

    var progress: Double {
        switch self {
        case .versionCheck: return 0.0
        case .gameCenterAuth: return 0.33
        case .dataLoading: return 0.66
        case .completed: return 1.0
        }
    }
}

struct LoadingView: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(AppRouter.self) var router
    @Environment(StoreKitManager.self) var storeKitManager

    @State private var currentStage: LoadingStage = .versionCheck
    @State private var progress: Double = 0.0
    @State private var isLoading = true
    @State private var versionManager = VersionManager.shared

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background(style: .image("background"))

            VStack(spacing: 30) {
                Spacer()

                // 로딩 프로그레스 바
                VStack(spacing: 20) {
                    // 프로그레스 바
                    ZStack(alignment: .leading) {
                        // 배경 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.dsSurface)
                            .frame(height: 8)

                        // 진행 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.magenta.opacity(0.8))
                            .frame(width: progress * 300, height: 8)
                    }
                    .frame(width: 300)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startLoadingProcess()
        }
        .fullScreenCover(isPresented: .constant(versionManager.shouldForceUpdate && !isLoading)) {
            // 강제 업데이트 화면 (닫을 수 없음)
            ForceUpdateView()
        }
        .fullScreenCover(isPresented: .constant(!versionManager.isServiceAvailable && versionManager.hasCheckedVersion && !isLoading)) {
            // 서비스 이용 불가 화면
            ServiceUnavailableView()
        }
    }

    private func updateStage(to newStage: LoadingStage) async {
        await MainActor.run {
            currentStage = newStage
            withAnimation(.easeInOut(duration: 0.5)) {
                progress = newStage.progress
            }
        }
    }

    private func startLoadingProcess() {
        Task {
            // 단계 1: 버전 체크 (서비스 체크 포함)
            await updateStage(to: .versionCheck)
            await versionManager.checkAppVersion()

            // 서비스 불가 또는 강제 업데이트 체크
            if !versionManager.isServiceAvailable {
                isLoading = false
                return
            }

            if versionManager.shouldForceUpdate {
                isLoading = false
                return
            }

            // 단계 2: Game Center 인증
            await updateStage(to: .gameCenterAuth)
            await proceedWithGameKitLoading()
        }
    }

    private func proceedWithGameKitLoading() async {
        // GameKit 뷰 컨트롤러 처리 설정
        setupGameKitCallbacks()

        // GameKit에서 플레이어 정보 가져오기
        let playerInfo = await gameKitManager.getPlayerInfoAsync()

        // 단계 3: Supabase 데이터 로딩 (사용자 + 스탯)
        await updateStage(to: .dataLoading)
        await loadUserDataFromDB(with: playerInfo)
    }

    private func loadUserDataFromDB(with playerInfo: GameKitManager.PlayerInfo) async {
        // GameKit에서 얻은 플레이어 정보로 데이터 로드/생성
        let playerID = playerInfo.playerID
        let nickname = playerInfo.nickname

        let request = LoadGameDataRequest(playerID: playerID, nickname: nickname)
        let _ = await useCaseFactory.loadGameData.execute(request)

        // IAP 상품 로드
        await loadStoreItems()
        
        // IAP 트랜잭션 모니터링 시작
        storeKitManager.startTransactionMonitoring()

        // 단계 4: 완료
        await updateStage(to: .completed)
        isLoading = false

        // 완료 후 다음 화면으로 이동
        await MainActor.run {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.router.currentRoute == .loading {
                    // 앱 처음 실행인지 확인
                    let hasSeenStory = UserDefaults.standard.bool(forKey: "hasSeenStory")

                    if hasSeenStory {
                        // 이미 본 적이 있으면 메인 화면으로 이동
                        self.router.navigate(to: .main)
                    } else {
                        // 처음이면 스토리 화면으로 이동
                        self.router.navigate(to: .story)
                    }
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
    }

    private func loadStoreItems() async {
        do {
            try await storeKitManager.loadProducts()
            print("✅ IAP 상품 로드 완료: \(storeKitManager.gemItems.count)개")
        } catch {
            print("❌ IAP 상품 로드 실패: \(error.localizedDescription)")
            // IAP 로드 실패해도 앱 실행은 계속 진행
        }
    }
}
