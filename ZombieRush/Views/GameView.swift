//
//  GameView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI
import SpriteKit

// MARK: - Game Scene ViewModel 제거됨 (GameStateManager로 통합)

struct GameView: View {
    @Environment(AppRouter.self) var router
    @Environment(GameKitManager.self) var gameKitManager

    private let gameStateManager: GameStateManager
    @State private var showPauseOverlay = false

    init(gameStateManager: GameStateManager) {
        self.gameStateManager = gameStateManager
    }
    
    var body: some View {
        ZStack {
            // SpriteKit 게임 씬 (풀스크린)
            SpriteView(scene: makeGameScene())
                .ignoresSafeArea()

            // 일시정지 오버레이
            if showPauseOverlay {
                pauseOverlay
            }
        }
        .onAppear {
            // 게임 상태 변경 알림 수신 설정
            NotificationCenter.default.addObserver(
                forName: GameStateManager.NotificationName.stateChanged,
                object: gameStateManager,
                queue: .main
            ) { notification in
                guard let userInfo = notification.userInfo,
                      let newState = userInfo["newState"] as? GameState else {
                    return
                }

                // GameStateManager의 상태 변화에 따라 overlay 표시/숨김
                switch newState {
                case .paused:
                    self.showPauseOverlay = true
                case .playing:
                    self.showPauseOverlay = false
                case .gameOver:
                    self.showPauseOverlay = false  // 게임 오버 시 overlay 숨김
                case .loading:
                    self.showPauseOverlay = false  // 로딩 중 overlay 숨김
                }
            }
        }
        .onDisappear {
            // 모든 Notification observer 정리
            NotificationCenter.default.removeObserver(self, name: GameStateManager.NotificationName.stateChanged, object: gameStateManager)
        }
    }
    
    // MARK: - Game Scene Creation
    private func makeGameScene() -> SKScene {
        let scene = GameScene(
            appRouter: router,
            gameKitManager: gameKitManager,
            gameStateManager: gameStateManager,
            ultimateSkill: NuclearAttackSkill()
        )

        // 콜백 설정 제거 - GameStateManager의 상태 변화를 통해 자동 처리

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
                Text(NSLocalizedString("PAUSE_TITLE", comment: "Pause overlay - Paused title"))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)

                // 버튼들
                VStack(spacing: 20) {
                    // 계속하기 버튼
                    StandardButton(
                        NSLocalizedString("PAUSE_RESUME_BUTTON", comment: "Pause overlay - Resume button text"),
                        width: 200,
                        color: .main,
                        action: {
                            resumeGame()
                        }
                    )

                    // 나가기 버튼
                    StandardButton(
                        NSLocalizedString("PAUSE_QUIT_BUTTON", comment: "Pause overlay - Quit button text"),
                        width: 200,
                        color: .warning,
                        action: {
                            quitToMainMenu()
                        }
                    )
                }
            }
        }
    }

    // MARK: - Actions
    // showPauseMenu 제거됨 - 콜백으로 직접 처리

    private func resumeGame() {
        // GameStateManager를 통해 게임 재개
        gameStateManager.resumeGame()

        // 나머지는 GameStateManager의 상태 변화에 따라 자동 처리됨
    }

    private func quitToMainMenu() {
        // GameStateManager를 통해 게임 재개 (나가기 전에 게임 재개)
        gameStateManager.resumeGame()

        // router.quitToMainMenu()에서 새로운 게임이 시작될 때 startNewGame()이 호출되어 상태가 초기화됨
        // 나머지는 GameStateManager의 상태 변화에 따라 자동 처리됨
        router.quitToMainMenu()
    }
}
