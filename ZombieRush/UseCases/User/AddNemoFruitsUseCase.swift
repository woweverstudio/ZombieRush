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

    func execute(_ request: AddNemoFruitsRequest) async throws -> AddNemoFruitsResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            throw NSError(domain: "AddNemoFruitsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다"])
        }

        // 네모열매 추가
        var updatedUser = currentUser
        updatedUser.nemoFruit += request.fruitsToAdd

        // DB 업데이트
        let savedUser = try await userRepository.updateUser(updatedUser)
        print("📱 UserUseCase: 네모열매 \(request.fruitsToAdd)개 추가 - 총 \(savedUser.nemoFruit)개")

        return AddNemoFruitsResponse(user: savedUser)
    }
}
