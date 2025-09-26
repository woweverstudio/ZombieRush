//
//  LoadOrCreateJobsUseCase.swift
//  ZombieRush
//
//  Created by Load or Create Jobs UseCase
//

import Foundation

struct LoadOrCreateJobsRequest {
    let playerID: String
}

struct LoadOrCreateJobsResponse {
    let jobs: Jobs
}

/// 직업 로드 또는 생성 UseCase
/// 플레이어 ID로 직업 데이터 로드 또는 생성
struct LoadOrCreateJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: LoadOrCreateJobsRequest) async -> LoadOrCreateJobsResponse {
        // 1. 직업 조회 시도
        do {
            if let existingJobs = try await jobsRepository.getJobs(by: request.playerID) {
                return LoadOrCreateJobsResponse(jobs: existingJobs)
            } else {
                // 2. 직업이 없으면 새로 생성
                let newJobs = Jobs.defaultJobs(for: request.playerID)
                let jobs = try await jobsRepository.createJobs(newJobs)
                return LoadOrCreateJobsResponse(jobs: jobs)
            }
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return LoadOrCreateJobsResponse(jobs: Jobs(playerId: ""))
        }
    }
}
