//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import UIKit
import Supabase
import AlertToast

@main
struct ZombieRushApp: App {
    // Repository instances (SSOT) - managed as StateObjects for proper lifecycle
    @StateObject var userRepository: SupabaseUserRepository
    @StateObject var statsRepository: SupabaseStatsRepository
    @StateObject var spiritsRepository: SupabaseSpiritsRepository
    @StateObject var jobsRepository: SupabaseJobsRepository

    // UseCaseFactory with injected repositories
    @StateObject var useCaseFactory: UseCaseFactory

    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()

    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var notificationManager = NotificationManager.shared
    @State private var errorManager = ErrorManager.shared
    @Bindable private var toastManager = ToastManager.shared

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

    init() {
        let userRepository = SupabaseUserRepository()
        let statsRepository = SupabaseStatsRepository()
        let spiritsRepository = SupabaseSpiritsRepository()
        let jobsRepository = SupabaseJobsRepository()
        
        // Initialize UseCaseFactory with injected repositories
        let factory = UseCaseFactory(
            userRepository: userRepository,
            statsRepository: statsRepository,
            spiritsRepository: spiritsRepository,
            jobsRepository: jobsRepository
        )
        
        _userRepository = StateObject(wrappedValue: userRepository)
        _statsRepository = StateObject(wrappedValue: statsRepository)
        _spiritsRepository = StateObject(wrappedValue: spiritsRepository)
        _jobsRepository = StateObject(wrappedValue: jobsRepository)
        _useCaseFactory = StateObject(wrappedValue: factory)
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
            .environmentObject(spiritsRepository)
            .environmentObject(jobsRepository)
            .environmentObject(useCaseFactory)  // UseCaseFactory via EnvironmentKey
            .environment(appRouter)
            .environment(gameKitManager)
            .environment(gameStateManager)
            .environment(audioManager)
            .environment(hapticManager)
            .environment(errorManager)
            .environment(toastManager)
            .toast(
                item: $toastManager.currentToast,
                duration: toastManager.currentToast?.duration ?? 2,
                tapToDismiss: true
            ) { toast in
                AlertToast(displayMode: .banner(.pop), type: .regular, title: toast?.title, subTitle: toast?.description)
            }
            .task {
                // 앱 시작 시 Notification 설정
                notificationManager.setupNotifications()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱 상태 변화 감지 및 GameStateManager에 전달
            switch newPhase {
            case .active:
                gameStateManager.setAppActive(true)
                // 배지 제거
                notificationManager.clearBadge()

            case .inactive, .background:
                gameStateManager.setAppActive(false)
                
            @unknown default:
                break
            }
        }
    }
}
