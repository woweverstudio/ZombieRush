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
    let alertManager: AlertManager

    /// 트랜잭션을 pending 상태로 저장
    func execute(transactionData: TransactionData) async -> Bool {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {            
            return false
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
        
        do {
            try await transactionRepository.saveTransaction(transactionData: newTransaction)
            return true
        } catch {
            alertManager.showError(.serverError)
            return false
        }
        
    }
}
