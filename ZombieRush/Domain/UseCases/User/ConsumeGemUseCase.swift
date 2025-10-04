//
//  ConsumeGemUseCase.swift
//  ZombieRush
//
//  Created by Consume Nemo gem UseCase
//

import Foundation

struct ConsumeGemRequest {
    let gemsToConsume: Int
}

struct ConsumeGemResponse {
    let success: Bool
    let user: User?
}

/// 젬 소비 UseCase
/// 젬을 소비
struct ConsumeGemUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: ConsumeGemRequest) async -> ConsumeGemResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return ConsumeGemResponse(success: false, user: nil)
        }

        // 젬 검증
        guard currentUser.gem >= request.gemsToConsume else {
            return ConsumeGemResponse(success: false, user: currentUser)
        }

        // 젬 차감
        var updatedUser = currentUser
        updatedUser.gem -= request.gemsToConsume

        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return ConsumeGemResponse(success: true, user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return ConsumeGemResponse(success: false, user: currentUser)
        }
        
    }
}
