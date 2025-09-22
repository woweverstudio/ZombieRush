//
//  SupabaseJobsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of JobsRepository
//

import Foundation
import Supabase

/// Supabase를 사용한 JobsRepository 구현체
class SupabaseJobsRepository: JobsRepository {
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

        return jobs.first
    }

    func createJobs(_ jobs: Jobs) async throws -> Jobs {
        let createdJobs: Jobs = try await supabase
            .from("jobs")
            .insert(jobs)
            .select("*")
            .single()
            .execute()
            .value

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

        return updatedJobs
    }

    func selectJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        guard let currentJobs = try await getJobs(by: playerID) else {
            throw NSError(domain: "JobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

        var updatedJobs = currentJobs
        updatedJobs.selectedJob = jobType.rawValue

        return try await updateJobs(updatedJobs)
    }

    func unlockJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        guard let currentJobs = try await getJobs(by: playerID) else {
            throw NSError(domain: "JobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

        var updatedJobs = currentJobs
        switch jobType {
        case .novice:
            updatedJobs.novice = true
        case .fireMage:
            updatedJobs.fireMage = true
        case .iceMage:
            updatedJobs.iceMage = true
        case .lightningMage:
            updatedJobs.lightningMage = true
        case .darkMage:
            updatedJobs.darkMage = true
        }

        return try await updateJobs(updatedJobs)
    }
}