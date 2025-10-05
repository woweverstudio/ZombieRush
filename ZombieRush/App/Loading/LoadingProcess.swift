//
//  LoadingProcess.swift
//  ZombieRush
//
//  Created by 김민성 on 10/6/25.
//

import SwiftUI

/// 로딩 단계 정의
enum LoadingStage: Int, CaseIterable {
    case checkConfig = 0
    case loadGameCenter
    case loadServerData
    case loadMarketData
    case completed

    var progress: Double {
        switch self {
        case .checkConfig: return 0.2
        case .loadGameCenter: return 0.4
        case .loadServerData: return 0.6
        case .loadMarketData: return 0.8
        case .completed: return 1.0
        }
    }
}

extension LoadingView {
    /// 앱 로딩 프로세스: 단 한 단계라도 실패하면 바로 게스트 모드 진입
    func startLoadingProcess() {
        Task {
            // 단계 1: 버전 체크 (서비스 체크 포함)
            await updateStage(to: .checkConfig)
            guard await configManager.checkServerConfig() else {
                await loginAsGuest()
                return
            }

            // 단계 2: Game Center Data 로드
            await updateStage(to: .loadGameCenter)
            guard let playerInfo = await loadGameCenterData() else {
                await loginAsGuest()
                return
            }
            
            // 단계 3: Supabase 데이터 로드 (데이터 없을 시 생성)
            await updateStage(to: .loadServerData)
            guard await loadUserDataFromDB(with: playerInfo) else {
                await loginAsGuest()
                return
            }
            
            // 단계 4: 마켓 데이터 로드
            await updateStage(to: .loadMarketData)
            guard await storeKitManager.loadProducts() else {
                return
            }
            
            // 단계 5: StoreKit 트랜잭션 모니터링 시작
            storeKitManager.startTransactionMonitoring()
            
            // 완료 후 다음 화면으로 이동
            await updateStage(to: .completed)
            await moveNextScreen()
        }
    }
    
    private func loginAsGuest() async {
        useCaseFactory.loginAsGuest.execute()
        await updateStage(to: .completed)
        await moveNextScreen()
    }
    
    private func loadGameCenterData() async -> GameKitManager.PlayerInfo? {
        // GameKit 뷰 컨트롤러 처리 설정
        setupGameKitCallbacks()

        // GameKit에서 플레이어 정보 가져오기
        let playerInfo = await gameKitManager.getPlayerInfoAsync()
        
        return playerInfo
    }

    private func loadUserDataFromDB(with playerInfo: GameKitManager.PlayerInfo) async -> Bool {
        // GameKit에서 얻은 플레이어 정보로 데이터 로드/생성
        let playerID = playerInfo.playerID
        let nickname = playerInfo.nickname
        
        let request = LoadGameDataRequest(playerID: playerID, nickname: nickname)
        let response = await useCaseFactory.loadGameData.execute(request)
        
        return response.success
    }
    
    private func moveNextScreen() async {
        await MainActor.run {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.router.currentRoute == .loading {
                    // 앱 처음 실행인지 확인
                    let hasSeenStory = UserDefaults.standard.bool(forKey: "hasSeenStory")

                    if hasSeenStory {
                        // 이미 본 적이 있으면 메인 화면으로 이동
                        self.router.navigate(to: .main)
                    } else {
                        // 처음이면 스토리 화면으로 이동
                        self.router.navigate(to: .story)
                    }
                }
            }
        }
    }

    private func setupGameKitCallbacks() {
        // 뷰 컨트롤러 표시 클로저 설정
        gameKitManager.presentViewController = { viewController in
            // 현재 표시된 뷰 컨트롤러 찾기
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(viewController, animated: true)
            }
        }

        // 뷰 컨트롤러 닫기 클로저 설정
        gameKitManager.dismissViewController = {
            // 현재 표시된 뷰 컨트롤러 닫기
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: true)
            }
        }
    }
    
    private func updateStage(to newStage: LoadingStage) async {
        await MainActor.run {
            currentStage = newStage
            withAnimation(.easeInOut(duration: 0.5)) {
                progress = newStage.progress
            }
        }
    }
}
