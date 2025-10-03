//
//  SupabaseSpiritsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of SpiritsRepository
//

import Foundation
import Supabase
import SwiftUI

/// Supabase를 사용한 SpiritsRepository 구현체
@MainActor
final class SupabaseSpiritsRepository: ObservableObject, SpiritsRepository {
    // Observable properties for View observation
    @Published var currentSpirits: Spirits?

    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    func getSpirits(by playerID: String) async throws -> Spirits? {
        let spirits: [Spirits] = try await supabase
            .from("spirits")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        let spirit = spirits.first
        currentSpirits = spirit
        return spirit
    }

    func createSpirits(_ spirits: Spirits) async throws -> Spirits {
        let createdSpirits: Spirits = try await supabase
            .from("spirits")
            .insert(spirits)
            .select("*")
            .single()
            .execute()
            .value

        currentSpirits = createdSpirits
        return createdSpirits
    }

    func updateSpirits(_ spirits: Spirits) async throws -> Spirits {
        let updatedSpirits: Spirits = try await supabase
            .from("spirits")
            .update([
                "fire": String(spirits.fire),
                "ice": String(spirits.ice),
                "thunder": String(spirits.thunder),
                "dark": String(spirits.dark)
            ])
            .eq("player_id", value: spirits.playerId)
            .select("*")
            .single()
            .execute()
            .value

        currentSpirits = updatedSpirits
        return updatedSpirits
    }

    /// 네모열매를 소비하여 원소 교환 (트랜잭션)
    func exchangeFruitForSpirit(playerID: String, spiritType: String, amount: Int) async throws -> (Spirits, User) {
        // RPC 호출 및 JSON 파싱
        let data = try await supabase
            .rpc("exchange_fruit_for_spirit", params: [
                "p_player_id": playerID,
                "p_spirit_type": spiritType,
                "p_amount": String(amount)
            ])
            .execute()
            .data

        // RPCDecoder로 간단하게 파싱
        let response = try RPCDecoder.decode(TransactionResponse.self, from: data)

        // Repository 상태 업데이트
        currentSpirits = response.spirits

        return (response.spirits, response.user)
    }

    // 트랜잭션 응답 구조체
    private struct TransactionResponse: Codable {
        let user: User
        let spirits: Spirits
    }

}
