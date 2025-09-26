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
    let jobs: Jobs?
}

/// 직업 선택 UseCase
/// 직업을 선택
struct SelectJobUseCase: UseCase {
    let jobsRepository: JobsRepository

    func execute(_ request: SelectJobRequest) async -> SelectJobResponse {
        // 현재 직업 정보 사용 (Repository의 currentJobs)
        guard let currentJobs = await jobsRepository.currentJobs else {
            ErrorManager.shared.report(.dataNotFound)
            return SelectJobResponse(jobs: nil)
        }

        // 직업 선택
        var updatedJobs = currentJobs
        updatedJobs.selectedJob = request.jobType.rawValue
        
        do {
            let savedJobs = try await jobsRepository.updateJobs(updatedJobs)
            return SelectJobResponse(jobs: savedJobs)
        } catch {            
            ToastManager.shared.show(.selectJobFailed)
            return SelectJobResponse(jobs: nil)
        }
        
    }
}
