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
        return jobs
    }

    func selectJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        selectJobCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentJobs = jobs[playerID] else {
            throw NSError(domain: "MockJobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

        currentJobs.selectedJob = jobType.rawValue
        jobs[playerID] = currentJobs
        return currentJobs
    }

    func unlockJob(for playerID: String, jobType: JobType) async throws -> Jobs {
        unlockJobCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentJobs = jobs[playerID] else {
            throw NSError(domain: "MockJobsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Jobs not found"])
        }

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

        jobs[playerID] = currentJobs
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