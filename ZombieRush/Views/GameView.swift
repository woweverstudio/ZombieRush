//
//  GameView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var router = AppRouter.shared
    
    var body: some View {
        // SpriteKit 게임 씬 (풀스크린)
        SpriteView(scene: makeGameScene())
            .ignoresSafeArea()
        .onAppear {
            // 게임 시작 시 게임용 BGM 재생
            AudioManager.shared.playGameMusic()
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