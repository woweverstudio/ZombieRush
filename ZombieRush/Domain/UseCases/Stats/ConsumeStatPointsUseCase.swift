//
//  ConsumeStatPointsUseCase.swift
//  ZombieRush
//
//  Created by Consume Stat Points UseCase
//

import Foundation

struct ConsumeStatPointsRequest {
    let pointsToConsume: Int
}

struct ConsumeStatPointsResponse {
    let success: Bool
    let user: User?
}

/// 스텟 포인트 소비 UseCase
/// 스텟 업그레이드를 위한 포인트 소비
struct ConsumeStatPointsUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: ConsumeStatPointsRequest) async throws -> ConsumeStatPointsResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            return ConsumeStatPointsResponse(success: false, user: nil)
        }

        // 포인트 검증
        guard currentUser.remainingPoints >= request.pointsToConsume else {
            print("📊 StatsUseCase: 포인트 부족 - needed: \(request.pointsToConsume), current: \(currentUser.remainingPoints)")
            return ConsumeStatPointsResponse(success: false, user: currentUser)
        }

        // 포인트 차감
        var updatedUser = currentUser
        updatedUser.remainingPoints -= request.pointsToConsume

        // DB 업데이트
        let savedUser = try await userRepository.updateUser(updatedUser)
        print("📊 StatsUseCase: 포인트 \(request.pointsToConsume)개 차감 완료 - 남은 포인트: \(savedUser.remainingPoints)")

        return ConsumeStatPointsResponse(success: true, user: savedUser)
    }
}
