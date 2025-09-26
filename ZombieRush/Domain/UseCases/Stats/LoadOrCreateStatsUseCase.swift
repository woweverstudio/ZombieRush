//
//  LoadOrCreateStatsUseCase.swift
//  ZombieRush
//
//  Created by Load or Create Stats UseCase
//

import Foundation

struct LoadOrCreateStatsRequest {
    let playerID: String
}

struct LoadOrCreateStatsResponse {
    let stats: Stats
}

/// 스텟 로드 또는 생성 UseCase
/// 플레이어 ID로 스텟 데이터 로드 또는 생성
struct LoadOrCreateStatsUseCase: UseCase {
    let statsRepository: StatsRepository

    func execute(_ request: LoadOrCreateStatsRequest) async throws -> LoadOrCreateStatsResponse {
        // 1. 스텟 조회 시도
        if let existingStats = try await statsRepository.getStats(by: request.playerID) {
            print("📊 StatsUseCase: 기존 스텟 로드 성공 - HP: \(existingStats.hpRecovery), Speed: \(existingStats.moveSpeed)")
            return LoadOrCreateStatsResponse(stats: existingStats)
        } else {
            // 2. 스텟이 없으면 새로 생성
            let newStats = Stats.defaultStats(for: request.playerID)
            let stats = try await statsRepository.createStats(newStats)
            print("📊 StatsUseCase: 새 스텟 생성 성공 - 기본값으로 초기화")
            return LoadOrCreateStatsResponse(stats: stats)
        }
    }
}
