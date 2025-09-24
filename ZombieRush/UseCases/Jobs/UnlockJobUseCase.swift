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
/// 정령을 소비하여 직업을 해금
struct UnlockJobUseCase: UseCase {
    let jobsRepository: JobsRepository
    let spiritsRepository: SpiritsRepository
    let userRepository: UserRepository

    func execute(_ request: UnlockJobRequest) async throws -> UnlockJobResponse {
        let stats = JobStats.getStats(for: request.jobType.rawValue)

        guard let requirement = stats.unlockRequirement else {
            // 해금 조건이 없는 경우 (novice 등)
            return try await unlockJobDirectly(jobType: request.jobType)
        }

        // 정령 개수 및 레벨 확인
        guard await canUnlockJob(requirement) else {
            print("🔥 정령 부족 또는 레벨 부족으로 \(request.jobType.displayName) 해금 실패")
            return UnlockJobResponse(success: false, jobs: nil)
        }

        // 정령 소비 및 직업 해금
        return try await unlockJobWithSpirits(requirement, jobType: request.jobType)
    }

    /// 해금 조건 확인
    private func canUnlockJob(_ requirement: JobUnlockRequirement) async -> Bool {
        // 정령 개수 확인
        guard let currentSpirits = spiritsRepository.currentSpirits else {
            return false
        }
        let currentSpiritCount = getSpiritCount(for: requirement.spiritType, from: currentSpirits)
        let hasEnoughSpirits = currentSpiritCount >= requirement.count

        // 레벨 확인
        guard let currentUser = userRepository.currentUser else {
            return false
        }
        let currentLevel = Level(currentExp: currentUser.exp).currentLevel
        let hasRequiredLevel = currentLevel >= requirement.requiredLevel

        return hasEnoughSpirits && hasRequiredLevel
    }

    /// 정령 소비 및 직업 해금
    private func unlockJobWithSpirits(_ requirement: JobUnlockRequirement, jobType: JobType) async throws -> UnlockJobResponse {
        // 정령 개수 차감
        guard let currentSpirits = spiritsRepository.currentSpirits else {
            return UnlockJobResponse(success: false, jobs: nil)
        }

        var updatedSpirits = currentSpirits
        let spiritTypeEnum = SpiritType(rawValue: requirement.spiritType) ?? .fire

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
        _ = try await spiritsRepository.updateSpirits(updatedSpirits)

        // 직업 해금
        let unlockResponse = try await unlockJobDirectly(jobType: jobType)
        print("🔥 직업 \(jobType.displayName) 해금 완료! \(requirement.spiritType) 정령 \(requirement.count)개 소비")

        return unlockResponse
    }

    /// 직업 직접 해금 (조건 없이)
    private func unlockJobDirectly(jobType: JobType) async throws -> UnlockJobResponse {
        // 현재 직업 정보 사용 (Repository의 currentJobs)
        guard let currentJobs = jobsRepository.currentJobs else {
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

        let savedJobs = try await jobsRepository.updateJobs(updatedJobs)
        print("🔓 직업 \(jobType.displayName) 해금됨")

        return UnlockJobResponse(success: true, jobs: savedJobs)
    }

    /// 정령 개수 추출 헬퍼
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
