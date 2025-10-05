//
//  AddGemUseCase.swift
//  ZombieRush
//
//  Created by Add Nemo gem UseCase
//

import Foundation

struct AddGemRequest {
    let transaction: TransactionData
}

struct AddGemResponse {
    let success: Bool
}

/// 젬 추가 UseCase
/// 젬을 추가
@MainActor
struct AddGemUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: AddGemRequest) async -> AddGemResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return AddGemResponse(success: false)
        }

        // 트랜잭션 완료 처리 및 gem 추가
        do {
            let newGemTotal = try await userRepository.completeGemPurchaseTransaction(transaction: request.transaction)

            // currentUser 업데이트 (gem 수량 동기화)
            let newUser = User(
                playerId: currentUser.playerId,
                nickname: currentUser.nickname,
                exp: currentUser.exp,
                gem: newGemTotal,
                remainingPoints: currentUser.remainingPoints,
                cheerBuffExpiresAt: currentUser.cheerBuffExpiresAt
            )
            
            userRepository.currentUser = newUser

            return AddGemResponse(success: true)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return AddGemResponse(success: false)
        }
    }
    
}
