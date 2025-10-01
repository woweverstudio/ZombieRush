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
/// 원소를 소비하여 직업을 해금
struct UnlockJobUseCase: UseCase {
    let jobsRepository: JobsRepository
    let spiritsRepository: SpiritsRepository
    let userRepository: UserRepository

    func execute(_ request: UnlockJobRequest) async -> UnlockJobResponse {
        let stats = JobStats.getStats(for: request.jobType.rawValue)

        guard let requirement = stats.unlockRequirement else {
            // 해금 조건이 없는 경우 (novice 등)
            return await unlockJobDirectly(jobType: request.jobType)
        }

        // 원소 개수 및 레벨 확인
        guard await canUnlockJob(requirement) else {
            return UnlockJobResponse(success: false, jobs: nil)
        }

        // 원소 소비 및 직업 해금
        return await unlockJobWithSpirits(requirement, jobType: request.jobType)
    }

    /// 해금 조건 확인
    private func canUnlockJob(_ requirement: JobUnlockRequirement) async -> Bool {
        // 원소 개수 확인
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            ErrorManager.shared.report(.dataNotFound)
            return false
        }
        let currentSpiritCount = getSpiritCount(for: requirement.spiritType, from: currentSpirits)
        let hasEnoughSpirits = currentSpiritCount >= requirement.count

        // 레벨 확인
        guard let currentUser = await userRepository.currentUser else {
            return false
        }
        let currentLevel = Level(currentExp: currentUser.exp).currentLevel
        let hasRequiredLevel = currentLevel >= requirement.requiredLevel

        if hasEnoughSpirits && hasRequiredLevel {
            return true
        } else {
            ToastManager.shared.show(.unlockJobFailed(requirement.spiritType, currentSpiritCount, currentLevel))
            return false
        }
    }

    /// 원소 소비 및 직업 해금
    private func unlockJobWithSpirits(_ requirement: JobUnlockRequirement, jobType: JobType) async -> UnlockJobResponse {
        // 원소 개수 차감
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            ErrorManager.shared.report(.dataNotFound)
            return UnlockJobResponse(success: false, jobs: nil)
        }
        
        guard let spiritTypeEnum = SpiritType(rawValue: requirement.spiritType) else {
            ErrorManager.shared.report(.dataNotFound)
            return UnlockJobResponse(success: false, jobs: nil)
        }
        
        var updatedSpirits = currentSpirits

        switch spiritTypeEnum {
        case .fire:
            updatedSpirits.fire -= requirement.count
        case .ice:
            updatedSpirits.ice -= requirement.count
        case .lightning:
            updatedSpirits.lightning -= requirement.count
        case .dark:
            updatedSpirits.dark -= requirement.count
        }

        // DB 업데이트
        do {
            _ = try await spiritsRepository.updateSpirits(updatedSpirits)
            let unlockResponse = await unlockJobDirectly(jobType: jobType)
            
            return unlockResponse
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return UnlockJobResponse(success: false, jobs: nil)
        }
        
    }

    /// 직업 직접 해금 (조건 없이)
    private func unlockJobDirectly(jobType: JobType) async -> UnlockJobResponse {
        // 현재 직업 정보 사용 (Repository의 currentJobs)
        guard let currentJobs = await jobsRepository.currentJobs else {
            ErrorManager.shared.report(.dataNotFound)
            return UnlockJobResponse(success: false, jobs: nil)
        }

        // 직업 해금
        var updatedJobs = currentJobs
        switch jobType {
        case .novice:
            updatedJobs.novice = true
        case .fireMage:
            updatedJobs.fireMage = true
        case .iceMage:
            updatedJobs.iceMage = true
        case .lightningMage:
            updatedJobs.lightningMage = true
        case .darkMage:
            updatedJobs.darkMage = true
        }
        
        do {
            let savedJobs = try await jobsRepository.updateJobs(updatedJobs)
            ToastManager.shared.show(.unlockJobSuccess(jobType.localizedDisplayName))

            return UnlockJobResponse(success: true, jobs: savedJobs)
        } catch {
            ToastManager.shared.show(.selectJobFailed)
            return UnlockJobResponse(success: false, jobs: nil)
        }
        
    }

    /// 원소 개수 추출 헬퍼
    private func getSpiritCount(for spiritType: String, from spirits: Spirits) -> Int {
        switch spiritType {
        case "fire": return spirits.fire
        case "ice": return spirits.ice
        case "lightning": return spirits.lightning
        case "dark": return spirits.dark
        default: return 0
        }
    }
}
