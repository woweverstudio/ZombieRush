//
//  SaveTransactionUseCase.swift
//  ZombieRush
//
//  Created by Save Transaction Use Case
//

import Foundation

/// 트랜잭션 저장 UseCase
@MainActor
struct SaveTransactionUseCase {
    let transactionRepository: TransactionRepository
    let userRepository: UserRepository

    /// 트랜잭션을 pending 상태로 저장
    func execute(transactionData: TransactionData) async throws {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return
        }
        
        // 현재 사용자 정보에서 직접 플레이어 ID를 가져와서 다시 조합
        let newTransaction = TransactionData(
            transactionId: transactionData.transactionId,
            playerId: currentUser.playerId,
            productId: transactionData.productId,
            status: transactionData.status,
            purchaseDate: transactionData.purchaseDate,
            jwsSignature: transactionData.jwsSignature
        )
        
        try await transactionRepository.saveTransaction(transactionData: newTransaction)
    }
}
