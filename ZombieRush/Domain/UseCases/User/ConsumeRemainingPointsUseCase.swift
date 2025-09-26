//
//  ConsumeRemainingPointsUseCase.swift
//  ZombieRush
//
//  Created by Consume Remaining Points UseCase
//

import Foundation

struct ConsumeRemainingPointsRequest {
    let pointsToConsume: Int
}

struct ConsumeRemainingPointsResponse {
    let success: Bool
    let user: User?
}

/// 남은 포인트 소비 UseCase
/// 사용자의 남은 포인트를 소비
struct ConsumeRemainingPointsUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: ConsumeRemainingPointsRequest) async -> ConsumeRemainingPointsResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return ConsumeRemainingPointsResponse(success: false, user: nil)
        }

        // 포인트 검증
        guard currentUser.remainingPoints >= request.pointsToConsume else {
            return ConsumeRemainingPointsResponse(success: false, user: currentUser)
        }

        // 포인트 차감
        var updatedUser = currentUser
        updatedUser.remainingPoints -= request.pointsToConsume

        // DB 업데이트
        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return ConsumeRemainingPointsResponse(success: true, user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return ConsumeRemainingPointsResponse(success: false, user: currentUser)
        }
        
    }
}
