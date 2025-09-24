//
//  ConsumeNemoFruitsUseCase.swift
//  ZombieRush
//
//  Created by Consume Nemo Fruits UseCase
//

import Foundation

struct ConsumeNemoFruitsRequest {
    let fruitsToConsume: Int
}

struct ConsumeNemoFruitsResponse {
    let success: Bool
    let user: User?
}

/// 네모열매 소비 UseCase
/// 네모열매를 소비
struct ConsumeNemoFruitsUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: ConsumeNemoFruitsRequest) async throws -> ConsumeNemoFruitsResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = userRepository.currentUser else {
            return ConsumeNemoFruitsResponse(success: false, user: nil)
        }

        // 네모열매 검증
        guard currentUser.nemoFruit >= request.fruitsToConsume else {
            print("📱 UserUseCase: 네모열매 부족 - needed: \(request.fruitsToConsume), current: \(currentUser.nemoFruit)")
            return ConsumeNemoFruitsResponse(success: false, user: currentUser)
        }

        // 네모열매 차감
        var updatedUser = currentUser
        updatedUser.nemoFruit -= request.fruitsToConsume

        // DB 업데이트
        let savedUser = try await userRepository.updateUser(updatedUser)
        print("📱 UserUseCase: 네모열매 소비 완료 - 남은 네모열매: \(savedUser.nemoFruit)")

        return ConsumeNemoFruitsResponse(success: true, user: savedUser)
    }
}
