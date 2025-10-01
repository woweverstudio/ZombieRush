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

}
