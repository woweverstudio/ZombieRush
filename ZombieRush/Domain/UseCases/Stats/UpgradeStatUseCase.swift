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

    func execute(_ request: UpgradeStatRequest) async -> UpgradeStatResponse {
        // 현재 스텟 정보 사용 (Repository의 currentStats)
        guard let currentStats = await statsRepository.currentStats else {
            ErrorManager.shared.report(.userNotFound)
            return UpgradeStatResponse(success: false, stats: nil)
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
        
        do {
            let savedStats = try await statsRepository.updateStats(updatedStats)
            ToastManager.shared.show(.statPointsIncreased(request.statType.localizedDisplayName, 1))
            return UpgradeStatResponse(success: true, stats: savedStats)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UpgradeStatResponse(success: false, stats: nil)
        }
        
    }
}
