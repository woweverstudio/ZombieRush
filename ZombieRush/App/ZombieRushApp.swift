//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

@main
struct ZombieRushApp: App {
    // UI 매니저들만 싱글턴 제거, 게임 로직 매니저들은 싱글턴 유지
    @State private var gameKitManager = GameKitManager()
    @State private var appRouter = AppRouter()
    @State private var audioManager = AudioManager.shared  // 게임에서 사용하므로 싱글턴 유지
    @State private var hapticManager = HapticManager.shared  // 게임에서 사용하므로 싱글턴 유지
    
    var body: some Scene {
        WindowGroup {
            ContentView()                
                .preferredColorScheme(.dark)
                .environment(gameKitManager)   // GameKit 매니저 주입
                .environment(appRouter)        // App Router 주입
                .environment(audioManager)     // Audio 매니저 주입
                .environment(hapticManager)    // Haptic 매니저 주입
                .onAppear {
                    // GameStateManager에 GameKitManager 의존성 주입
                    GameStateManager.shared.setGameKitManager(gameKitManager)
                    
                    // 앱 시작 시 즉시 메인메뉴 음악 재생
                    audioManager.playMainMenuMusic()
                    
                    // 앱 시작 시 GameKit 인증 시도
                    gameKitManager.startAuthentication()
                }
        }
    }
}
