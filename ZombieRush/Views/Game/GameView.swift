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
    @Environment(GameStateManager.self) var gameStateManager
    
    @State private var gameScene: GameScene?   // SKScene 상속 객체
    
    var body: some View {
        ZStack {
            // SpriteKit 게임 씬 (풀스크린)
            if let gameScene = gameScene {
                SpriteView(scene: gameScene)
                    .ignoresSafeArea()
            }

            // 일시정지 오버레이
            if gameStateManager.currentState == .paused {
                pauseOverlay
            }
        }
        .onAppear {
            if gameScene == nil {
                let gameScene = GameScene(
                    appRouter: router,
                    gameKitManager: gameKitManager,
                    gameStateManager: gameStateManager,
                    ultimateSkill: NuclearAttackSkill()
                )
                
                let screenSize = UIScreen.main.bounds.size
                gameScene.size = CGSize(width: screenSize.width, height: screenSize.height)
                gameScene.scaleMode = .aspectFill
                
                self.gameScene = gameScene
            }
        }
    }
    
    // MARK: - Game Scene Creation
    private func makeGameScene(_ gameStateManager: GameStateManager) -> SKScene {
        let scene = GameScene(
            appRouter: router,
            gameKitManager: gameKitManager,
            gameStateManager: gameStateManager,
            ultimateSkill: NuclearAttackSkill()
        )

        // 화면 크기를 한 번만 계산하여 캐시
        let screenSize = UIScreen.main.bounds.size
        scene.size = CGSize(width: screenSize.width, height: screenSize.height)
        scene.scaleMode = .aspectFill
        return scene
    }

    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            // 반투명한 검은색 배경
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // 일시정지 메뉴
            VStack(spacing: 30) {
                // 제목
                Text(TextConstants.Pause.title)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)

                // 버튼들
                HStack(spacing: 20) {
                    // 나가기 버튼
                    StandardButton(
                        TextConstants.Pause.quitButton,
                        width: 200,
                        color: .warning,
                        action: {
                            gameScene?.clearGameNodes()
                            router.quitToMain()
                        }
                    )
                    
                    // 계속하기 버튼
                    StandardButton(
                        TextConstants.Pause.resumeButton,
                        width: 200,
                        color: .main,
                        action: {
                            gameScene?.resumeGame()
                        }
                    )
                }
            }
        }
    }
}
