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
    let jobs: Jobs
}

/// 직업 데이터 새로고침 UseCase
/// 최신 직업 정보를 가져옴
struct RefreshJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: RefreshJobsRequest) async throws -> RefreshJobsResponse {
        // currentJobs의 playerID를 사용해서 서버에서 다시 조회
        guard let currentJobs = jobsRepository.currentJobs else {
            throw NSError(domain: "RefreshJobsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 직업 정보가 없습니다"])
        }

        guard let jobs = try await jobsRepository.getJobs(by: currentJobs.playerId) else {
            throw NSError(domain: "RefreshJobsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "직업 정보를 찾을 수 없습니다"])
        }
        print("⚔️ JobsUseCase: 직업 새로고침 성공")
        return RefreshJobsResponse(jobs: jobs)
    }
}
