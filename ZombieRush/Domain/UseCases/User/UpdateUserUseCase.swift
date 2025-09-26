//
//  UpdateUserUseCase.swift
//  ZombieRush
//
//  Created by Update User UseCase
//

import Foundation

struct UpdateUserRequest {
    let user: User
}

struct UpdateUserResponse {
    let user: User?
}

/// 사용자 업데이트 UseCase
/// 사용자 정보를 업데이트
struct UpdateUserUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: UpdateUserRequest) async -> UpdateUserResponse {
        do {
            let updatedUser = try await userRepository.updateUser(request.user)
            return UpdateUserResponse(user: updatedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UpdateUserResponse(user: nil)
        }
    }
}
