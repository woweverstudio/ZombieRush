//
//  AddExperienceUseCase.swift
//  ZombieRush
//
//  Created by Add Experience UseCase
//

import Foundation

struct AddExperienceRequest {
    let expToAdd: Int
}

struct AddExperienceResponse {
    let user: User
    let leveledUp: Bool
    let levelsGained: Int
}

/// 경험치 추가 UseCase
/// 경험치를 추가하고 레벨업 처리를 수행
struct AddExperienceUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: AddExperienceRequest) async throws -> AddExperienceResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = userRepository.currentUser else {
            throw NSError(domain: "AddExperienceUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다"])
        }

        // 경험치 추가 및 레벨 계산
        let result = Level.addExperience(currentExp: currentUser.exp, expToAdd: request.expToAdd)
        let newLevel = result.newLevel
        let leveledUp = result.leveledUp
        let levelsGained = result.levelsGained

        // 사용자 정보 업데이트
        var updatedUser = currentUser
        updatedUser.exp = newLevel.currentExp

        // 레벨업 시 remaining_points 증가
        if leveledUp {
            updatedUser.remainingPoints += levelsGained * 3
        }

        // DB 업데이트
        let savedUser = try await userRepository.updateUser(updatedUser)
        print("📱 UserUseCase: 경험치 \(request.expToAdd) 추가 - 레벨: \(newLevel.currentLevel), EXP: \(newLevel.currentExp)")

        return AddExperienceResponse(
            user: savedUser,
            leveledUp: leveledUp,
            levelsGained: levelsGained
        )
    }
}
