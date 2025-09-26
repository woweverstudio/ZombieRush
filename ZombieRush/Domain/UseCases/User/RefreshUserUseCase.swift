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
    let user: User?
}

/// 사용자 데이터 새로고침 UseCase
/// 최신 사용자 정보를 가져옴
struct RefreshUserUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: RefreshUserRequest) async -> RefreshUserResponse {
        // currentUser의 playerID를 사용해서 서버에서 다시 조회
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return RefreshUserResponse(user: nil)
        }
        
        do {
            guard let user = try await userRepository.getUser(by: currentUser.playerId) else {
                ErrorManager.shared.report(.databaseRequestFailed)
                return RefreshUserResponse(user: nil)
            }
            
            return RefreshUserResponse(user: user)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return RefreshUserResponse(user: nil)
        }
        
    }
}
