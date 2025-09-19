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
    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()
    @State private var userStateManager = UserStateManager()  // 사용자 상태 관리
    @State private var statsStateManager = StatsStateManager()  // 사용자 스탯 관리
    @State private var spiritsStateManager = SpiritsStateManager()  // 정령 관리
    @State private var jobsStateManager = JobsStateManager()  // 직업 관리
    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var notificationManager = NotificationManager.shared

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

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
