//
//  Processor.swift
//  ZombieRush
//
//  Created by 김민성 on 10/6/25.
//

import SwiftUI

@MainActor
@Observable
final class Processor {
    var progress: Double = 0
    
    func start(
        useCaseFactory: UseCaseFactory,
        configManager: ConfigManager,
        gameKitManager: GameKitManager,
        storeKitManager: StoreKitManager
    ) async {

        // 단계 0: 오디오 초기화
        AudioManager.shared.initializeAudioManager()
        progress = 0.1

        // 단계 1: 버전 체크 (서비스 체크 포함)
        guard await configManager.checkServerConfig() else {
            loginAsGuest(useCaseFactory)
            return
        }
        progress = 0.3

        // 단계 2: Game Center Data 로드
        guard let playerInfo = await loadGameCenterData(gameKitManager) else {
            loginAsGuest(useCaseFactory)
            return
        }
        progress = 0.5

        // 단계 3: Supabase 데이터 로드 (데이터 없을 시 생성)
        guard await loadServerData(with: playerInfo, using: useCaseFactory) else {
            loginAsGuest(useCaseFactory)
            return
        }
        progress = 0.7

        // 단계 4: 마켓 데이터 로드
        guard await storeKitManager.loadProducts() else {
            loginAsGuest(useCaseFactory)
            return
        }
        progress = 0.9

        // 단계 5: StoreKit 트랜잭션 모니터링 시작
        storeKitManager.startTransactionMonitoring()
        progress = 1.0
    }
    
    private func loginAsGuest(_ useCaseFactory: UseCaseFactory) {
        useCaseFactory.loginAsGuest.execute()
        progress = 1.0
    }
    
    private func loadGameCenterData(_ gameKitManager: GameKitManager) async -> GameKitManager.PlayerInfo? {
        // GameKit에서 플레이어 정보 가져오기
        let playerInfo = await gameKitManager.getPlayerInfoAsync()
        
        return playerInfo
    }
    
    private func loadServerData(
        with playerInfo: GameKitManager.PlayerInfo,
        using useCaseFactory: UseCaseFactory
    ) async -> Bool {
        // GameKit에서 얻은 플레이어 정보로 데이터 로드/생성
        let playerID = playerInfo.playerID
        let nickname = playerInfo.nickname
        
        let request = LoadGameDataRequest(playerID: playerID, nickname: nickname)
        let response = await useCaseFactory.loadGameData.execute(request)
        
        return response.success
    }
}
