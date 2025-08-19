//
//  GameView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameScene: GameScene?
    
    var body: some View {
        // SpriteKit 게임 씬 (풀스크린)
        SpriteView(scene: makeGameScene())
            .ignoresSafeArea()
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .onAppear {
            // 게임 시작 시 게임용 BGM 재생
            AudioManager.shared.playGameMusic()
            
            // 게임 종료 알림 등록
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(GameConstants.Notifications.quitGame),
                object: nil,
                queue: .main
            ) { _ in
                dismiss()
            }
        }
        .onDisappear {
            // 게임 종료 시 메인 메뉴 음악으로 전환
            AudioManager.shared.playMainMenuMusic()
            
            // 알림 해제
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(GameConstants.Notifications.quitGame), object: nil)
        }
    }
    
    // MARK: - Game Scene Creation
    private func makeGameScene() -> SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .aspectFill
        return scene
    }
}

#Preview {
    GameView()
}