//
//  AddGemUseCase.swift
//  ZombieRush
//
//  Created by Add Nemo gem UseCase
//

import Foundation

struct AddGemRequest {
    let gemsToAdd: Int
}

struct AddGemResponse {
    let user: User
}

/// 젬 추가 UseCase
/// 젬을 추가
struct AddGemUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: AddGemRequest) async -> AddGemResponse? {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return nil
        }

        // 젬 추가
        var updatedUser = currentUser
        updatedUser.gem += request.gemsToAdd

        // DB 업데이트
        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return AddGemResponse(user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return nil
        }
    }
    
}
