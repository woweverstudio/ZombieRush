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
/// 스텟을 업그레이드하고 포인트를 소비 (트랜잭션)
@MainActor
struct UpgradeStatUseCase: UseCase {
    let statsRepository: StatsRepository
    let userRepository: UserRepository

    func execute(_ request: UpgradeStatRequest) async -> UpgradeStatResponse {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return UpgradeStatResponse(success: false, stats: nil)
        }

        do {
            // 트랜잭션으로 스텟 업그레이드 및 포인트 차감
            let (updatedUser, updatedStats) = try await statsRepository.upgradeStatWithTransaction(
                playerID: currentUser.playerId,
                statType: request.statType
            )

            // Repository의 currentUser와 currentStats 업데이트
            userRepository.currentUser = updatedUser
            statsRepository.currentStats = updatedStats

            ToastManager.shared.show(.statPointsIncreased(request.statType.localizedDisplayName, 1))
            return UpgradeStatResponse(success: true, stats: updatedStats)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UpgradeStatResponse(success: false, stats: nil)
        }

    }
}
