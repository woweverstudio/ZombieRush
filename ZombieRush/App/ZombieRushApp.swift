//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import UIKit

@main
struct ZombieRushApp: App {
    // DIContainer에서 Repository들을 가져와 StateManager 생성
    private let container = DIContainer.shared

    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()

    // @Observable 호환을 위해 @State로 직접 선언
    @State private var userStateManager: UserStateManager
    @State private var statsStateManager: StatsStateManager
    @State private var spiritsStateManager: SpiritsStateManager
    @State private var jobsStateManager: JobsStateManager

    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var notificationManager = NotificationManager.shared

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

    init() {
        // DIContainer의 factory methods로 @Observable StateManager들 생성
        userStateManager = container.makeUserStateManager()
        statsStateManager = container.makeStatsStateManager()
        spiritsStateManager = container.makeSpiritsStateManager()
        jobsStateManager = container.makeJobsStateManager()
    }

    var body: some Scene {
        WindowGroup {
            // 일반 앱 화면
            RouterView()
                .preferredColorScheme(.dark)
                .environment(appRouter)
                .environment(gameKitManager)
                .environment(gameStateManager)
                .environment(userStateManager)
                .environment(statsStateManager)
                .environment(spiritsStateManager)
                .environment(jobsStateManager)
                .environment(audioManager)
                .environment(hapticManager)
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
