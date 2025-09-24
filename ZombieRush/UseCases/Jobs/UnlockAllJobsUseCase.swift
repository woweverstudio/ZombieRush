//
//  UnlockAllJobsUseCase.swift
//  ZombieRush
//
//  Created by Unlock All Jobs UseCase
//

import Foundation

struct UnlockAllJobsRequest {
}

struct UnlockAllJobsResponse {
    let jobs: Jobs
}

/// 모든 직업 잠금 해제 UseCase
/// 모든 직업을 잠금 해제 (치트/테스트용)
struct UnlockAllJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: UnlockAllJobsRequest) async throws -> UnlockAllJobsResponse {
        // 현재 직업 정보 사용 (Repository의 currentJobs)
        guard let currentJobs = jobsRepository.currentJobs else {
            throw NSError(domain: "UnlockAllJobsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "직업 정보를 찾을 수 없습니다"])
        }

        // 모든 직업 잠금 해제
        var updatedJobs = currentJobs
        updatedJobs.novice = true
        updatedJobs.fireMage = true
        updatedJobs.iceMage = true
        updatedJobs.lightningMage = true
        updatedJobs.darkMage = true

        let savedJobs = try await jobsRepository.updateJobs(updatedJobs)
        print("⚔️ JobsUseCase: 모든 직업 잠금 해제됨")

        return UnlockAllJobsResponse(jobs: savedJobs)
    }
}
