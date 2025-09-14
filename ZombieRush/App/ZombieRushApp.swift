//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

@main
struct ZombieRushApp: App {
    @State private var appRouter = AppRouter()
    @State private var gameKitManager = GameKitManager()
    @State private var gameStateManager = GameStateManager()
    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지

    @Environment(\.scenePhase) private var scenePhase  // 앱 상태 모니터링

    var body: some Scene {
        WindowGroup {
            // 일반 앱 화면
            RouterView()
                .preferredColorScheme(.dark)
                .environment(appRouter)
                .environment(gameKitManager)
                .environment(gameStateManager)
                .environment(audioManager)
                .environment(hapticManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱 상태 변화 감지 및 GameStateManager에 전달
            switch newPhase {
            case .active:
                gameStateManager.setAppActive(true)
                print("📱 앱이 활성화됨 - 플레이 시간 측정 재개")
            case .inactive, .background:
                gameStateManager.setAppActive(false)
                print("📱 앱이 비활성화됨 - 플레이 시간 측정 일시정지")
            @unknown default:
                break
            }
        }
    }
}
