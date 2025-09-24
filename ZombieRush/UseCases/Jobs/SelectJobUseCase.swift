//
//  SelectJobUseCase.swift
//  ZombieRush
//
//  Created by Select Job UseCase
//

import Foundation

struct SelectJobRequest {
    let jobType: JobType
}

struct SelectJobResponse {
    let jobs: Jobs
}

/// 직업 선택 UseCase
/// 직업을 선택
struct SelectJobUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: SelectJobRequest) async throws -> SelectJobResponse {
        // 현재 직업 정보 사용 (Repository의 currentJobs)
        guard let currentJobs = jobsRepository.currentJobs else {
            throw NSError(domain: "SelectJobUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "직업 정보를 찾을 수 없습니다"])
        }

        // 직업 선택
        var updatedJobs = currentJobs
        updatedJobs.selectedJob = request.jobType.rawValue

        let savedJobs = try await jobsRepository.updateJobs(updatedJobs)
        print("⚔️ JobsUseCase: 직업 선택 완료 - \(request.jobType.displayName)")

        return SelectJobResponse(jobs: savedJobs)
    }
}
