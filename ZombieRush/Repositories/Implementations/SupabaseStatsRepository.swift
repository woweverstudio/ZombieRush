//
//  SupabaseStatsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of StatsRepository
//

import Foundation
import Supabase

/// Supabase를 사용한 StatsRepository 구현체
class SupabaseStatsRepository: StatsRepository {
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

        return createdStats
    }

    func updateStats(_ stats: Stats) async throws -> Stats {
        let updatedStats: Stats = try await supabase
            .from("stats")
            .update([
                "hp_recovery": String(stats.hpRecovery),
                "move_speed": String(stats.moveSpeed),
                "energy_recovery": String(stats.energyRecovery),
                "attack_speed": String(stats.attackSpeed),
                "totem_count": String(stats.totemCount)
            ])
            .eq("player_id", value: stats.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedStats
    }

    func upgradeStat(for playerID: String, statType: StatType) async throws -> Stats {
        guard let currentStats = try await getStats(by: playerID) else {
            throw NSError(domain: "StatsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Stats not found"])
        }

        var updatedStats = currentStats

        switch statType {
        case .hpRecovery:
            updatedStats.hpRecovery += 1
        case .moveSpeed:
            updatedStats.moveSpeed += 1
        case .energyRecovery:
            updatedStats.energyRecovery += 1
        case .attackSpeed:
            updatedStats.attackSpeed += 1
        case .totemCount:
            updatedStats.totemCount += 1
        }

        return try await updateStats(updatedStats)
    }
}
