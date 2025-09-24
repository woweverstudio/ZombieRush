//
//  PurchaseCheerBuffUseCase.swift
//  ZombieRush
//
//  Created by Purchase Cheer Buff UseCase
//

import Foundation

struct PurchaseCheerBuffRequest {
    let duration: TimeInterval
}

struct PurchaseCheerBuffResponse {
    let success: Bool
    let user: User?
}

/// 응원 버프 구매 UseCase
/// 응원 버프를 구매
struct PurchaseCheerBuffUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: PurchaseCheerBuffRequest) async throws -> PurchaseCheerBuffResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = userRepository.currentUser else {
            return PurchaseCheerBuffResponse(success: false, user: nil)
        }

        // 이미 활성화된 응원이 있는지 확인
        if currentUser.isCheerBuffActive {
            print("📱 UserUseCase: 응원 버프 이미 활성화됨")
            return PurchaseCheerBuffResponse(success: false, user: currentUser)
        }

        let expirationDate = Date().addingTimeInterval(request.duration)

        var updatedUser = currentUser
        updatedUser.cheerBuffExpiresAt = expirationDate

        let savedUser = try await userRepository.updateUser(updatedUser)
        print("📱 UserUseCase: 응원 버프 구매 완료 - 만료시간: \(expirationDate)")

        return PurchaseCheerBuffResponse(success: true, user: savedUser)
    }
}
