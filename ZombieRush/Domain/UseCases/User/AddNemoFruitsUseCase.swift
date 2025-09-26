//
//  AddNemoFruitsUseCase.swift
//  ZombieRush
//
//  Created by Add Nemo Fruits UseCase
//

import Foundation

struct AddNemoFruitsRequest {
    let fruitsToAdd: Int
}

struct AddNemoFruitsResponse {
    let user: User
}

/// 네모열매 추가 UseCase
/// 네모열매를 추가
struct AddNemoFruitsUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: AddNemoFruitsRequest) async -> AddNemoFruitsResponse? {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return nil
        }

        // 네모열매 추가
        var updatedUser = currentUser
        updatedUser.nemoFruit += request.fruitsToAdd

        // DB 업데이트
        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return AddNemoFruitsResponse(user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return nil
        }
    }
    
}
