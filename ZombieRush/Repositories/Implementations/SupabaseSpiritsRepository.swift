//
//  SupabaseSpiritsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of SpiritsRepository
//

import Foundation
import Supabase

/// Supabase를 사용한 SpiritsRepository 구현체
class SupabaseSpiritsRepository: SpiritsRepository {
    private let supabase: SupabaseClient

    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: SpiritsDataChangeCallback?

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

        return spirits.first
    }

    func createSpirits(_ spirits: Spirits) async throws -> Spirits {
        let createdSpirits: Spirits = try await supabase
            .from("spirits")
            .insert(spirits)
            .select("*")
            .single()
            .execute()
            .value

        return createdSpirits
    }

    func updateSpirits(_ spirits: Spirits) async throws -> Spirits {
        let updatedSpirits: Spirits = try await supabase
            .from("spirits")
            .update([
                "fire": String(spirits.fire),
                "ice": String(spirits.ice),
                "lightning": String(spirits.lightning),
                "dark": String(spirits.dark)
            ])
            .eq("player_id", value: spirits.playerId)
            .select("*")
            .single()
            .execute()
            .value

        // 데이터 변경 콜백 호출
        await onDataChanged?()

        return updatedSpirits
    }

    func addSpirit(for playerID: String, spiritType: SpiritType, count: Int) async throws -> Spirits {
        guard let currentSpirits = try await getSpirits(by: playerID) else {
            throw NSError(domain: "SpiritsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Spirits not found"])
        }

        var updatedSpirits = currentSpirits

        switch spiritType {
        case .fire:
            updatedSpirits.fire += count
        case .ice:
            updatedSpirits.ice += count
        case .lightning:
            updatedSpirits.lightning += count
        case .dark:
            updatedSpirits.dark += count
        }

        return try await updateSpirits(updatedSpirits)
    }
}