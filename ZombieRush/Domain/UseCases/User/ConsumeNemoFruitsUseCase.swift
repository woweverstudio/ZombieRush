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

    func execute(_ request: ConsumeNemoFruitsRequest) async -> ConsumeNemoFruitsResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return ConsumeNemoFruitsResponse(success: false, user: nil)
        }

        // 네모열매 검증
        guard currentUser.nemoFruit >= request.fruitsToConsume else {
            return ConsumeNemoFruitsResponse(success: false, user: currentUser)
        }

        // 네모열매 차감
        var updatedUser = currentUser
        updatedUser.nemoFruit -= request.fruitsToConsume
        
        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return ConsumeNemoFruitsResponse(success: true, user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return ConsumeNemoFruitsResponse(success: false, user: currentUser)
        }
        
    }
}
