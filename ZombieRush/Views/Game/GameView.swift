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
    
    @State private var gameScene: GameScene?   // SKScene 상속 객체
    
    var body: some View {
        ZStack {
            // SpriteKit 게임 씬 (풀스크린)
            if let gameScene = gameScene {
                SpriteView(scene: gameScene)
                    .ignoresSafeArea()
            }

            // 일시정지 오버레이
            // TODO: GameStateManager가 제거되었으므로 게임 씬에서 직접 상태 관리
            // if gameScene?.isPaused == true {
            //     pauseOverlay
            // }
        }
        .onAppear {
            if gameScene == nil {
                let gameScene = GameScene(
                    appRouter: router,
                    gameKitManager: gameKitManager,
                    gameStateManager: GameStateManager(),
                    ultimateSkill: NuclearAttackSkill()
                )
                
                let screenSize = UIScreen.main.bounds.size
                gameScene.size = CGSize(width: screenSize.width, height: screenSize.height)
                gameScene.scaleMode = .aspectFill
                
                self.gameScene = gameScene
            }
        }
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
                    PrimaryButton(
                        title: TextConstants.Pause.quitButton,
                        style: .red,
                        width: 200,
                        height: 50,
                        action: {
                            gameScene?.clearGameNodes()
                            router.quitToMain()
                        }
                    )

                    // 계속하기 버튼
                    PrimaryButton(
                        title: TextConstants.Pause.resumeButton,
                        style: .cyan,
                        width: 200,
                        height: 50,
                        action: {
                            gameScene?.resumeGame()
                        }
                    )
                }
            }
        }
    }
}
