//
//  MockSpiritsRepository.swift
//  ZombieRush
//
//  Created by Mock Implementation of SpiritsRepository for Testing
//

import Foundation

/// 테스트용 SpiritsRepository Mock 구현체
class MockSpiritsRepository: SpiritsRepository {
    // MARK: - Mock Data
    var spirits: [String: Spirits] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockSpiritsRepository", code: -1, userInfo: nil)

    // MARK: - Call Tracking (Optional)
    var getSpiritsCallCount = 0
    var createSpiritsCallCount = 0
    var updateSpiritsCallCount = 0
    var addSpiritCallCount = 0

    // MARK: - Protocol Implementation
    func getSpirits(by playerID: String) async throws -> Spirits? {
        getSpiritsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return spirits[playerID]
    }

    func createSpirits(_ spirits: Spirits) async throws -> Spirits {
        createSpiritsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.spirits[spirits.playerId] = spirits
        return spirits
    }

    func updateSpirits(_ spirits: Spirits) async throws -> Spirits {
        updateSpiritsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        self.spirits[spirits.playerId] = spirits
        return spirits
    }

    func addSpirit(for playerID: String, spiritType: SpiritType, count: Int) async throws -> Spirits {
        addSpiritCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var currentSpirits = spirits[playerID] else {
            throw NSError(domain: "MockSpiritsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Spirits not found"])
        }

        switch spiritType {
        case .fire:
            currentSpirits.fire += count
        case .ice:
            currentSpirits.ice += count
        case .lightning:
            currentSpirits.lightning += count
        case .dark:
            currentSpirits.dark += count
        }

        spirits[playerID] = currentSpirits
        return currentSpirits
    }

    // MARK: - Helper Methods
    func reset() {
        spirits.removeAll()
        shouldThrowError = false
        getSpiritsCallCount = 0
        createSpiritsCallCount = 0
        updateSpiritsCallCount = 0
        addSpiritCallCount = 0
    }
}