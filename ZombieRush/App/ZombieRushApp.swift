//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import UIKit
import Supabase

@main
struct ZombieRushApp: App {
    // Repository instances (SSOT) - managed as StateObjects for proper lifecycle
    @StateObject var userRepository = SupabaseUserRepository()
    @StateObject var statsRepository = SupabaseStatsRepository()
    @StateObject var spiritsRepository = SupabaseSpiritsRepository()
    @StateObject var jobsRepository = SupabaseJobsRepository()

    // UseCaseFactory with injected repositories
    @StateObject var useCaseFactory: UseCaseFactory

    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()

    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var notificationManager = NotificationManager.shared

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

    init() {
        // Initialize UseCaseFactory with injected repositories
        let factory = UseCaseFactory(
            userRepository: SupabaseUserRepository(),
            statsRepository: SupabaseStatsRepository(),
            spiritsRepository: SupabaseSpiritsRepository(),
            jobsRepository: SupabaseJobsRepository()
        )
        _useCaseFactory = StateObject(wrappedValue: factory)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 일반 앱 화면
                RouterView()
                    .preferredColorScheme(.dark)

                // 전역 에러 오버레이 (항상 최상단)
                ErrorOverlayView()
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
            .environment(GlobalErrorManager.shared)
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
