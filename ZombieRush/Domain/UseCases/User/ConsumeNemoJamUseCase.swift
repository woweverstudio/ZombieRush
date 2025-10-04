//
//  ConsumeNemoJamUseCase.swift
//  ZombieRush
//
//  Created by Consume Nemo Jam UseCase
//

import Foundation

struct ConsumeNemoJamRequest {
    let jamToConsume: Int
}

struct ConsumeNemoJamResponse {
    let success: Bool
    let user: User?
}

/// 네모잼 소비 UseCase
/// 네모잼을 소비
struct ConsumeNemoJamUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: ConsumeNemoJamRequest) async -> ConsumeNemoJamResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return ConsumeNemoJamResponse(success: false, user: nil)
        }

        // 네모잼 검증
        guard currentUser.nemoJam >= request.jamToConsume else {
            return ConsumeNemoJamResponse(success: false, user: currentUser)
        }

        // 네모잼 차감
        var updatedUser = currentUser
        updatedUser.nemoJam -= request.jamToConsume

        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return ConsumeNemoJamResponse(success: true, user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return ConsumeNemoJamResponse(success: false, user: currentUser)
        }
        
    }
}
