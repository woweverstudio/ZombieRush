//
//  SupabaseJobsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of JobsRepository
//

import Foundation
import Supabase
import SwiftUI

/// Supabase를 사용한 JobsRepository 구현체
@MainActor
class SupabaseJobsRepository: ObservableObject, JobsRepository {
    // Observable properties for View observation
    @Published var currentJobs: Jobs?

    private let supabase: SupabaseClient


    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    func getJobs(by playerID: String) async throws -> Jobs? {
        let jobs: [Jobs] = try await supabase
            .from("jobs")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        let job = jobs.first
        currentJobs = job
        return job
    }

    func createJobs(_ jobs: Jobs) async throws -> Jobs {
        let createdJobs: Jobs = try await supabase
            .from("jobs")
            .insert(jobs)
            .select("*")
            .single()
            .execute()
            .value

        currentJobs = createdJobs
        return createdJobs
    }

    func updateJobs(_ jobs: Jobs) async throws -> Jobs {
        let updatedJobs: Jobs = try await supabase
            .from("jobs")
            .update([
                "novice": jobs.novice ? "true" : "false",
                "fire_mage": jobs.fireMage ? "true" : "false",
                "ice_mage": jobs.iceMage ? "true" : "false",
                "lightning_mage": jobs.lightningMage ? "true" : "false",
                "dark_mage": jobs.darkMage ? "true" : "false",
                "selected_job": jobs.selectedJob
            ])
            .eq("player_id", value: jobs.playerId)
            .select("*")
            .single()
            .execute()
            .value

        currentJobs = updatedJobs
        return updatedJobs
    }

}
