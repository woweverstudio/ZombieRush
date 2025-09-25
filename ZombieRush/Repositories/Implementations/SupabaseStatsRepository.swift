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
class SupabaseStatsRepository: ObservableObject, StatsRepository {
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
        do {
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
        } catch {
            // ✅ 네트워크/DB 실패 시 네트워크 에러 표시
            GlobalErrorManager.shared.showError(.network(.serverError(code: 500)))
            throw error
        }
    }

}
