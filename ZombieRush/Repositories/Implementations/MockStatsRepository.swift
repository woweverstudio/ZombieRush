//
//  MockStatsRepository.swift
//  ZombieRush
//
//  Created by Mock Implementation of StatsRepository for Testing
//

import Foundation

/// 테스트용 StatsRepository Mock 구현체
class MockStatsRepository: StatsRepository {
    // MARK: - Mock Data
    var stats: [String: Stats] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockStatsRepository", code: -1, userInfo: nil)

    // MARK: - Call Tracking (Optional)
    var getStatsCallCount = 0
    var createStatsCallCount = 0
    var updateStatsCallCount = 0
    var upgradeStatCallCount = 0

    // MARK: - Protocol Implementation
    func getStats(by playerID: String) async throws -> Stats? {
        getStatsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return stats[playerID]
    }

    func createStats(_ stats: Stats) async throws -> Stats {
        createStatsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.stats[stats.playerId] = stats
        return stats
    }

    func updateStats(_ stats: Stats) async throws -> Stats {
        updateStatsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.stats[stats.playerId] = stats
        return stats
    }

    func upgradeStat(for playerID: String, statType: StatType) async throws -> Stats {
        upgradeStatCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentStats = stats[playerID] else {
            throw NSError(domain: "MockStatsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Stats not found"])
        }

        switch statType {
        case .hpRecovery:
            currentStats.hpRecovery += 1
        case .moveSpeed:
            currentStats.moveSpeed += 1
        case .energyRecovery:
            currentStats.energyRecovery += 1
        case .attackSpeed:
            currentStats.attackSpeed += 1
        case .totemCount:
            currentStats.totemCount += 1
        }

        stats[playerID] = currentStats
        return currentStats
    }

    // MARK: - Helper Methods
    func reset() {
        stats.removeAll()
        shouldThrowError = false
        getStatsCallCount = 0
        createStatsCallCount = 0
        updateStatsCallCount = 0
        upgradeStatCallCount = 0
    }
}
