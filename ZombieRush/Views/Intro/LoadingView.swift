import SwiftUI

extension LoadingView {
    static let checkingVersionMessage = NSLocalizedString("checking_version_message", tableName: "Intro", comment: "Checking version message")
    static let loadingDataMessage = NSLocalizedString("loading_data_message", tableName: "Intro", comment: "Loading data message")
    static let syncingUserDataMessage = NSLocalizedString("syncing_user_data_message", tableName: "Intro", comment: "Syncing user data message")
    static let readyToPlayMessage = NSLocalizedString("ready_to_play_message", tableName: "Intro", comment: "Ready to play message")
    static let gameTitleLine1 = NSLocalizedString("game_title_line_1", tableName: "Intro", comment: "Game title line 1")
    static let gameTitleLine2 = NSLocalizedString("game_title_line_2", tableName: "Intro", comment: "Game title line 2")
}

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

    var message: String {
        switch self {
        case .versionCheck: return LoadingView.checkingVersionMessage
        case .gameCenterAuth: return LoadingView.loadingDataMessage
        case .dataLoading: return LoadingView.syncingUserDataMessage
        case .completed: return LoadingView.readyToPlayMessage
        }
    }
}

struct LoadingView: View {
    @Environment(GameKitManager.self) var gameKitManager
    @Environment(GameStateManager.self) var gameStateManager
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    @Environment(AppRouter.self) var router

    @State private var currentStage: LoadingStage = .versionCheck
    @State private var progress: Double = 0.0
    @State private var isLoading = true
    @State private var versionManager = VersionManager.shared

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 30) {
                Spacer()

                // 게임 타이틀 (로딩 화면용으로 크게)
                VStack(spacing: max(40 * 0.2, 8)) {
                    Text(verbatim: LoadingView.gameTitleLine1)
                        .font(.system(size: 40, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 1.0))
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0), radius: 15, x: 0, y: 0)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.5), radius: 30, x: 0, y: 0)

                    Text(verbatim: LoadingView.gameTitleLine2)
                        .font(.system(size: 60, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 20, x: 0, y: 0)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.5), radius: 40, x: 0, y: 0)
                }


                // 로딩 프로그레스 바
                VStack(spacing: 20) {
                    // 프로그레스 바
                    ZStack(alignment: .leading) {
                        // 배경 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.dsCard)
                            .frame(height: 8)

                        // 진행 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.magenta.opacity(0.8))
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
    
    private func getLoadingText() -> String {
        return currentStage.message
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


        // 사용자 데이터, 스탯 데이터, 원소 데이터, 직업 데이터 동시에 로드
        async let userTask: () = loadUserData(playerID: playerID, nickname: nickname)
        async let statsTask: () = loadStatsData(playerID: playerID)
        async let spiritsTask: () = loadSpiritsData(playerID: playerID)
        async let jobsTask: () = loadJobsData(playerID: playerID)

        // 네 작업 모두 완료될 때까지 대기
        await userTask
        await statsTask
        await spiritsTask
        await jobsTask

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

    private func loadUserData(playerID: String, nickname: String) async {
        let request = LoadOrCreateUserRequest(playerID: playerID, nickname: nickname)
        _ = await useCaseFactory.loadOrCreateUser.execute(request)
    }

    private func loadStatsData(playerID: String) async {
        let request = LoadOrCreateStatsRequest(playerID: playerID)
        _ = await useCaseFactory.loadOrCreateStats.execute(request)
    }

    private func loadSpiritsData(playerID: String) async {
        let request = LoadOrCreateSpiritsRequest(playerID: playerID)
        _ = await useCaseFactory.loadOrCreateSpirits.execute(request)
    }

    private func loadJobsData(playerID: String) async {
        let request = LoadOrCreateJobsRequest(playerID: playerID)
        _ = await useCaseFactory.loadOrCreateJobs.execute(request)
    }
}
