//
//  LoadOrCreateUserUseCase.swift
//  ZombieRush
//
//  Created by Load or Create User UseCase
//

import Foundation

struct LoadOrCreateUserRequest {
    let playerID: String
    let nickname: String
}

struct LoadOrCreateUserResponse {
    let user: User
}

/// 사용자 로드 또는 생성 UseCase
/// Game Center playerID를 사용해 사용자 데이터 로드 또는 생성
struct LoadOrCreateUserUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: LoadOrCreateUserRequest) async -> LoadOrCreateUserResponse {
        do {
            // 1. 사용자 조회 시도
            if let existingUser = try await userRepository.getUser(by: request.playerID) {
                // 2. 닉네임 확인 및 업데이트
                let user = try await checkAndUpdateNicknameIfNeeded(existingUser, newNickname: request.nickname)
                ToastManager.shared.show(.loginSuccess(user.nickname))
                return LoadOrCreateUserResponse(user: user)
            } else {
                // 3. 사용자가 없으면 새로 생성
                let newUser = User(playerId: request.playerID, nickname: request.nickname)
                let user = try await userRepository.createUser(newUser)
                ToastManager.shared.show(.loginSuccess(user.nickname))
                return LoadOrCreateUserResponse(user: user)
            }
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return LoadOrCreateUserResponse(user: .guestUser)
        }
    }

    /// 닉네임 변경 확인 및 업데이트
    private func checkAndUpdateNicknameIfNeeded(_ existingUser: User, newNickname: String) async throws -> User {
        // 닉네임이 변경되었는지 확인
        if existingUser.nickname != newNickname {
            var updatedUser = existingUser
            updatedUser.nickname = newNickname
            let result = try await userRepository.updateUser(updatedUser)
            return result
        } else {
            return existingUser
        }
    }
}
