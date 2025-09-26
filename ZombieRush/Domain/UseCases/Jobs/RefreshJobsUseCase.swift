//
//  RefreshJobsUseCase.swift
//  ZombieRush
//
//  Created by Refresh Jobs UseCase
//

import Foundation

struct RefreshJobsRequest {
}

struct RefreshJobsResponse {
    let jobs: Jobs?
}

/// 직업 데이터 새로고침 UseCase
/// 최신 직업 정보를 가져옴
struct RefreshJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: RefreshJobsRequest) async -> RefreshJobsResponse {
        // currentJobs의 playerID를 사용해서 서버에서 다시 조회
        guard let currentJobs = await jobsRepository.currentJobs else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshJobsResponse(jobs: nil)
        }
        
        
        guard let jobs = try? await jobsRepository.getJobs(by: currentJobs.playerId) else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshJobsResponse(jobs: nil)
        }
        
        return RefreshJobsResponse(jobs: jobs)
    }
}
