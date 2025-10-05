//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import AlertToast

@main
struct ZombieRushApp: App {
    // Repository instances (SSOT) - managed as StateObjects for proper lifecycle
    @StateObject var userRepository: SupabaseUserRepository
    @StateObject var statsRepository: SupabaseStatsRepository
    @StateObject var elementsRepository: SupabaseElementsRepository
    @StateObject var jobsRepository: SupabaseJobsRepository

    // UseCaseFactory with injected repositories
    @StateObject var useCaseFactory: UseCaseFactory

    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()
    @State private var storeKitManager: StoreKitManager

    @State private var errorManager = ErrorManager.shared
    @State private var toastManager = ToastManager.shared

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

    init() {
        let userRepository = SupabaseUserRepository()
        let statsRepository = SupabaseStatsRepository()
        let elementsRepository = SupabaseElementsRepository()
        let jobsRepository = SupabaseJobsRepository()
        let transactionRepository = SupabaseTransactionRepository()

        // StateObject 먼저 초기화
        _userRepository = StateObject(wrappedValue: userRepository)
        _statsRepository = StateObject(wrappedValue: statsRepository)
        _elementsRepository = StateObject(wrappedValue: elementsRepository)
        _jobsRepository = StateObject(wrappedValue: jobsRepository)

        // Initialize UseCaseFactory with injected repositories
        let factory = UseCaseFactory(
            userRepository: userRepository,
            statsRepository: statsRepository,
            elementsRepository: elementsRepository,
            jobsRepository: jobsRepository,
            transactionRepository: transactionRepository
        )
        _useCaseFactory = StateObject(wrappedValue: factory)
        _storeKitManager = State(initialValue: StoreKitManager(useCaseFactory: factory))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 일반 앱 화면
                RouterView()
                    .preferredColorScheme(.dark)
                
                ErrorView()
            }
            .environmentObject(userRepository)  // Repositories via EnvironmentKey
            .environmentObject(statsRepository)
            .environmentObject(elementsRepository)
            .environmentObject(jobsRepository)
            .environmentObject(useCaseFactory)  // UseCaseFactory via EnvironmentKey
            .environment(appRouter)
            .environment(gameKitManager)
            .environment(gameStateManager)
            .environment(storeKitManager)
            .environment(errorManager)
            .toast(
                item: $toastManager.currentToast,
                duration: toastManager.currentToast?.duration ?? 2,
                tapToDismiss: true
            ) { toast in
                let type = toast?.type ?? .complete
                return AlertToast(displayMode: .banner(.pop), type: .systemImage(type.imageName, type.color) , title: toast?.title, subTitle: toast?.description)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱 상태 변화 감지 및 GameStateManager에 전달
            switch newPhase {
            case .active:
                gameStateManager.setAppActive(true)

            case .inactive, .background:
                gameStateManager.setAppActive(false)
                
            @unknown default:
                break
            }
        }
    }

}
