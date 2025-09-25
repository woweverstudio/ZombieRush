//
//  ResetJobsUseCase.swift
//  ZombieRush
//
//  Created by Reset Jobs UseCase
//

import Foundation

struct ResetJobsRequest {
}

struct ResetJobsResponse {
    let jobs: Jobs
}

/// 직업 리셋 UseCase
/// 직업을 기본 상태로 리셋
struct ResetJobsUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: ResetJobsRequest) async throws -> ResetJobsResponse {
        // currentJobs의 playerID를 사용해서 새로 생성
        guard let currentJobs = await jobsRepository.currentJobs else {
            throw NSError(domain: "ResetJobsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 직업 정보를 찾을 수 없습니다"])
        }

        let resetJobs = Jobs.defaultJobs(for: currentJobs.playerId)
        let savedJobs = try await jobsRepository.updateJobs(resetJobs)

        print("⚔️ JobsUseCase: 직업 리셋 완료 - 기본값으로 초기화")

        return ResetJobsResponse(jobs: savedJobs)
    }
}
