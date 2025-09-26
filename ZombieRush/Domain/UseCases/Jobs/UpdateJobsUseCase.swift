//
//  UpdateJobsUseCase.swift
//  ZombieRush
//
//  Created by Update Jobs UseCase
//

import Foundation

struct UpdateJobsRequest {
    let jobs: Jobs
}

struct UpdateJobsResponse {
    let jobs: Jobs?
}

/// 직업 업데이트 UseCase
/// 직업 정보를 업데이트
struct UpdateJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: UpdateJobsRequest) async throws -> UpdateJobsResponse {
        do {
            let updatedJobs = try await jobsRepository.updateJobs(request.jobs)
            return UpdateJobsResponse(jobs: updatedJobs)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UpdateJobsResponse(jobs: nil)
        }
        
    }
}
