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
final class SupabaseJobsRepository: ObservableObject, JobsRepository {
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
                "fire": jobs.fireMage ? "true" : "false",
                "ice": jobs.iceMage ? "true" : "false",
                "thunder": jobs.thunderMage ? "true" : "false",
                "dark": jobs.darkMage ? "true" : "false",
                "selected": jobs.selectedJob
            ])
            .eq("player_id", value: jobs.playerId)
            .select("*")
            .single()
            .execute()
            .value

        currentJobs = updatedJobs
        return updatedJobs
    }

    func unlockJobWithTransaction(playerID: String, jobKey: String) async throws -> (jobs: Jobs, elements: Elements) {
        // RPC 호출
        let data = try await supabase
            .rpc("unlock_job_with_transaction", params: [
                "p_player_id": playerID,
                "p_job_key": jobKey
            ])
            .execute()
            .data

        // JSON 파싱 (RPC custom date format 지원)
        let response = try RPCDecoder.decode(TransactionUnlockResponse.self, from: data)

        // 성공 여부 확인
        guard response.success else {
            throw NSError(domain: "UnlockJobError", code: 0, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Unknown error"])
        }

        return (jobs: response.jobs, elements: response.elements)
    }

    // 트랜잭션 응답 구조체
    private struct TransactionUnlockResponse: Codable {
        let success: Bool
        let jobs: Jobs
        let elements: Elements
        let error: String?
    }

}
