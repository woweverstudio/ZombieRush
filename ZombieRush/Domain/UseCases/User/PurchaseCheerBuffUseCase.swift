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

    func execute(_ request: PurchaseCheerBuffRequest) async -> PurchaseCheerBuffResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = await userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return PurchaseCheerBuffResponse(success: false, user: nil)
        }

        let expirationDate = Date().addingTimeInterval(request.duration)

        var updatedUser = currentUser
        updatedUser.cheerBuffExpiresAt = expirationDate

        do {
            let savedUser = try await userRepository.updateUser(updatedUser)
            return PurchaseCheerBuffResponse(success: true, user: savedUser)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return PurchaseCheerBuffResponse(success: false, user: nil)
        }
        
    }
}
