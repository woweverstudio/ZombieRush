//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

@main
struct ZombieRushApp: App {
    // GameKit 매니저 초기화
    @StateObject private var gameKitManager = GameKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(gameKitManager)  // GameKit 매니저 주입
        }
    }
}
