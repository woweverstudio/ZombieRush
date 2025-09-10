//
//  GameView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager
    
    var body: some View {
        // SpriteKit 게임 씬 (풀스크린)
        SpriteView(scene: makeGameScene())
            .ignoresSafeArea()
    }
    
    // MARK: - Game Scene Creation
    private func makeGameScene() -> SKScene {
        let scene = GameScene(
            appRouter: router,
            gameKitManager: gameKitManager,
            ultimateSkill: NuclearAttackSkill()
        )
        // 화면 크기를 한 번만 계산하여 캐시
        let screenSize = UIScreen.main.bounds.size
        scene.size = CGSize(width: screenSize.width, height: screenSize.height)
        scene.scaleMode = .aspectFill
        return scene
    }
}
