//
//  UnlockJobUseCase.swift
//  ZombieRush
//
//  Created by Unlock Job UseCase
//

import Foundation

struct UnlockJobRequest {
    let jobType: JobType
}

struct UnlockJobResponse {
    let success: Bool
    let jobs: Jobs?
}

/// 직업 해금 UseCase
/// 원소를 소비하여 직업을 해금 (트랜잭션)
@MainActor
struct UnlockJobUseCase: UseCase {
    let jobsRepository: JobsRepository
    let elementsRepository: ElementsRepository
    let userRepository: UserRepository

    func execute(_ request: UnlockJobRequest) async -> UnlockJobResponse {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return UnlockJobResponse(success: false, jobs: nil)
        }

        do {
            // 트랜잭션으로 직업 해금 및 정령 차감
            let (updatedJobs, updatedElements) = try await jobsRepository.unlockJobWithTransaction(
                playerID: currentUser.playerId,
                jobKey: request.jobType.rawValue
            )

            // Repository 업데이트
            jobsRepository.currentJobs = updatedJobs
            elementsRepository.currentElements = updatedElements

            ToastManager.shared.show(.unlockJobSuccess(request.jobType.localizedDisplayName))
            return UnlockJobResponse(success: true, jobs: updatedJobs)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UnlockJobResponse(success: false, jobs: nil)
        }
    }
}
