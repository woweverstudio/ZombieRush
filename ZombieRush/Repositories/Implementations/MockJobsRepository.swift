//
//  MockJobsRepository.swift
//  ZombieRush
//
//  Created by Mock Implementation of JobsRepository for Testing
//

import Foundation

/// 테스트용 JobsRepository Mock 구현체
class MockJobsRepository: JobsRepository {
    // MARK: - Mock Data
    var jobs: [String: Jobs] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockJobsRepository", code: -1, userInfo: nil)

    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: JobsDataChangeCallback?

    // MARK: - Call Tracking (Optional)
    var getJobsCallCount = 0
    var createJobsCallCount = 0
    var updateJobsCallCount = 0
    var selectJobCallCount = 0
    var unlockJobCallCount = 0

    // MARK: - Protocol Implementation
    func getJobs(by playerID: String) async throws -> Jobs? {
        getJobsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return jobs[playerID]
    }

    func createJobs(_ jobs: Jobs) async throws -> Jobs {
        createJobsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.jobs[jobs.playerId] = jobs
        return jobs
    }

    func updateJobs(_ jobs: Jobs) async throws -> Jobs {
        updateJobsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.jobs[jobs.playerId] = jobs

        // 데이터 변경 콜백 호출
        await onDataChanged?()

        return jobs
    }

    func selectJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        selectJobCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentJobs = jobs[playerID] else {
            throw NSError(domain: "MockJobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

        // 직업이 잠금 해제되어 있는지 확인
        guard currentJobs.unlockedJobs.contains(jobType) else {
            throw NSError(domain: "MockJobsRepository", code: 403, userInfo: [NSLocalizedDescriptionKey: "Job not unlocked"])
        }

        // 직업 선택
        currentJobs.selectedJob = jobType.rawValue
        self.jobs[playerID] = currentJobs
        return currentJobs
    }

    func unlockJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        unlockJobCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentJobs = jobs[playerID] else {
            throw NSError(domain: "MockJobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

        // 직업 잠금 해제
        switch jobType {
        case .novice:
            currentJobs.novice = true
        case .fireMage:
            currentJobs.fireMage = true
        case .iceMage:
            currentJobs.iceMage = true
        case .lightningMage:
            currentJobs.lightningMage = true
        case .darkMage:
            currentJobs.darkMage = true
        }

        self.jobs[playerID] = currentJobs
        return currentJobs
    }

    // MARK: - Helper Methods
    func reset() {
        jobs.removeAll()
        shouldThrowError = false
        getJobsCallCount = 0
        createJobsCallCount = 0
        updateJobsCallCount = 0
        selectJobCallCount = 0
        unlockJobCallCount = 0
    }
}