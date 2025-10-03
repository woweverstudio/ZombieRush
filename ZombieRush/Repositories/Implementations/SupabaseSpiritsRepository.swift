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

}
