//
//  TransactionRepository.swift
//  ZombieRush
//
//  Created by Transaction Repository Protocol
//

import Foundation

/// 트랜잭션 저장소 프로토콜
protocol TransactionRepository {
    /// 트랜잭션 저장
    func saveTransaction(transactionData: TransactionData) async throws
}
