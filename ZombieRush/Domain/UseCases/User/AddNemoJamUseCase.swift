//
//  AddNemoJamUseCase.swift
//  ZombieRush
//
//  Created by Add Nemo Jam UseCase
//

import Foundation

struct AddNemoJamRequest {
    let jamToAdd: Int
}

struct AddNemoJamResponse {
    let user: User
}

/// 네모잼 추가 UseCase
/// 네모잼을 추가
struct AddNemoJamUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: AddNemoJamRequest) async -> AddNemoJamResponse? {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return nil
        }

        // 네모잼 추가
        var updatedUser = currentUser
        updatedUser.nemoJam += request.jamToAdd

        // DB 업데이트
        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return AddNemoJamResponse(user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return nil
        }
    }
    
}
