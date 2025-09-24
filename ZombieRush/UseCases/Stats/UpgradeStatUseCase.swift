//
//  UpgradeStatUseCase.swift
//  ZombieRush
//
//  Created by Upgrade Stat UseCase
//

import Foundation

struct UpgradeStatRequest {
    let statType: StatType
}

struct UpgradeStatResponse {
    let success: Bool
    let stats: Stats?
}

/// 스텟 업그레이드 UseCase
/// 스텟을 업그레이드하고 포인트를 소비
struct UpgradeStatUseCase: UseCase {
    let statsRepository: StatsRepository
    let consumePointsUseCase: ConsumeStatPointsUseCase

    func execute(_ request: UpgradeStatRequest) async throws -> UpgradeStatResponse {
        // 현재 스텟 정보 사용 (Repository의 currentStats)
        guard let currentStats = statsRepository.currentStats else {
            print("📊 StatsUseCase: 업그레이드 실패 - 스텟 데이터가 없습니다")
            return UpgradeStatResponse(success: false, stats: nil)
        }

        // 포인트 차감
        let consumePointsRequest = ConsumeStatPointsRequest(pointsToConsume: 1)
        let consumeResponse = try await consumePointsUseCase.execute(consumePointsRequest)

        if !consumeResponse.success {
            print("📊 StatsUseCase: 포인트 부족: 업그레이드 실패")
            return UpgradeStatResponse(success: false, stats: currentStats)
        }

        // 스텟 업그레이드
        var updatedStats = currentStats
        switch request.statType {
        case .hpRecovery:
            updatedStats.hpRecovery += 1
        case .moveSpeed:
            updatedStats.moveSpeed += 1
        case .energyRecovery:
            updatedStats.energyRecovery += 1
        case .attackSpeed:
            updatedStats.attackSpeed += 1
        case .totemCount:
            updatedStats.totemCount += 1
        }

        let savedStats = try await statsRepository.updateStats(updatedStats)
        print("📊 StatsUseCase: \(request.statType.displayName) 업그레이드 완료 (+1)")

        return UpgradeStatResponse(success: true, stats: savedStats)
    }
}
