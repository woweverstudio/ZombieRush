//
//  RefreshUserUseCase.swift
//  ZombieRush
//
//  Created by Refresh User UseCase
//

import Foundation

struct RefreshUserRequest {
}

struct RefreshUserResponse {
    let user: User
}

/// 사용자 데이터 새로고침 UseCase
/// 최신 사용자 정보를 가져옴
struct RefreshUserUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: RefreshUserRequest) async throws -> RefreshUserResponse {
        // currentUser의 playerID를 사용해서 서버에서 다시 조회
        guard let currentUser = await userRepository.currentUser else {
            throw NSError(domain: "RefreshUserUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 사용자가 없습니다"])
        }

        guard let user = try await userRepository.getUser(by: currentUser.playerId) else {
            throw NSError(domain: "RefreshUserUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다"])
        }
        print("📱 UserUseCase: 사용자 새로고침 성공 - \(user.nickname)")
        return RefreshUserResponse(user: user)
    }
}
