//
//  RefreshStatsUseCase.swift
//  ZombieRush
//
//  Created by Refresh Stats UseCase
//

import Foundation

struct RefreshStatsRequest {
}

struct RefreshStatsResponse {
    let stats: Stats?
}

/// 스텟 데이터 새로고침 UseCase
/// 최신 스텟 정보를 가져옴
struct RefreshStatsUseCase: UseCase {
    let statsRepository: StatsRepository

    func execute(_ request: RefreshStatsRequest) async -> RefreshStatsResponse {
        // currentStats의 playerID를 사용해서 서버에서 다시 조회
        guard let currentStats = await statsRepository.currentStats else {
            ErrorManager.shared.report(.userNotFound)
            return RefreshStatsResponse(stats: nil)
        }
        
        
        guard let stats = try? await statsRepository.getStats(by: currentStats.playerId) else {
            ErrorManager.shared.report(.databaseRequestFailed)
            return RefreshStatsResponse(stats: nil)
        }
        
        return RefreshStatsResponse(stats: stats)
    }
}
