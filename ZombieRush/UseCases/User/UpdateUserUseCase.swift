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
    let user: User
}

/// 사용자 업데이트 UseCase
/// 사용자 정보를 업데이트
struct UpdateUserUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: UpdateUserRequest) async throws -> UpdateUserResponse {
        let updatedUser = try await userRepository.updateUser(request.user)
        print("📱 UserUseCase: 사용자 업데이트 성공")
        return UpdateUserResponse(user: updatedUser)
    }
}
