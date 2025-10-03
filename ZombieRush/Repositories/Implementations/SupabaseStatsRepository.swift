//
//  SupabaseStatsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of StatsRepository
//

import Foundation
import Supabase
import SwiftUI

/// Supabase를 사용한 StatsRepository 구현체
@MainActor
final class SupabaseStatsRepository: ObservableObject, StatsRepository {
    // Observable properties for View observation
    @Published var currentStats: Stats?

    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    func getStats(by playerID: String) async throws -> Stats? {
        let stats: [Stats] = try await supabase
            .from("stats")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value
        
        currentStats = stats.first
        return stats.first
    }

    func createStats(_ stats: Stats) async throws -> Stats {
        let createdStats: Stats = try await supabase
            .from("stats")
            .insert(stats)
            .select("*")
            .single()
            .execute()
            .value
        
        currentStats = createdStats
        return createdStats
    }

    func updateStats(_ stats: Stats) async throws -> Stats {
        let updatedStats: Stats = try await supabase
            .from("stats")
            .update([
                "hp": String(stats.hp),
                "move_speed": String(stats.moveSpeed),
                "energy": String(stats.energy),
                "attack_speed": String(stats.attackSpeed)
            ])
            .eq("player_id", value: stats.playerId)
            .select("*")
            .single()
            .execute()
            .value

        currentStats = updatedStats
        return updatedStats
    }

    func upgradeStatWithTransaction(playerID: String, statType: StatType) async throws -> (user: User, stats: Stats) {
        // 전체 응답을 Data로 받고 파싱
        let data = try await supabase
            .rpc("upgrade_stat_with_transaction", params: [
                "p_player_id": playerID,
                "p_stat_type": statType.rawValue
            ])
            .execute()
            .data

        // JSON 파싱 (RPC custom date format 지원)
        let response = try RPCDecoder.decode(TransactionResponse.self, from: data)

        return (user: response.user, stats: response.stats)
    }

    // 트랜잭션 응답 구조체
    private struct TransactionResponse: Codable {
        let user: User
        let stats: Stats
    }

}
