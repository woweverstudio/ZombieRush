//
//  SupabaseTransactionRepository.swift
//  ZombieRush
//
//  Created by Supabase Transaction Repository Implementation
//

import Foundation
import Supabase

/// Supabase 트랜잭션 저장소 구현체
final class SupabaseTransactionRepository: TransactionRepository {
    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    /// 트랜잭션 저장
    func saveTransaction(transactionData: TransactionData) async throws {
        // Encodable 구조체로 변환하여 타입 안전성 확보
        try await supabase
            .from("transactions")
            .insert(transactionData)
            .execute()
    }
}
