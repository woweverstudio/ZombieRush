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
    let stats: Stats
}

/// 스텟 데이터 새로고침 UseCase
/// 최신 스텟 정보를 가져옴
struct RefreshStatsUseCase: UseCase {
    let statsRepository: StatsRepository

    func execute(_ request: RefreshStatsRequest) async throws -> RefreshStatsResponse {
        // currentStats의 playerID를 사용해서 서버에서 다시 조회
        guard let currentStats = await statsRepository.currentStats else {
            throw NSError(domain: "RefreshStatsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 스텟 정보가 없습니다"])
        }

        guard let stats = try await statsRepository.getStats(by: currentStats.playerId) else {
            throw NSError(domain: "RefreshStatsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "스텟 정보를 찾을 수 없습니다"])
        }
        print("📊 StatsUseCase: 스텟 새로고침 성공")
        return RefreshStatsResponse(stats: stats)
    }
}
