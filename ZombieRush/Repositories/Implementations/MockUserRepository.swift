//
//  MockUserRepository.swift
//  ZombieRush
//
//  Created by Mock Implementation of UserRepository for Testing
//

import Foundation

/// 테스트용 UserRepository Mock 구현체
class MockUserRepository: UserRepository {
    // MARK: - Mock Data
    var users: [String: User] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockUserRepository", code: -1, userInfo: nil)

    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: UserDataChangeCallback?

    // MARK: - Call Tracking (Optional)
    var getUserCallCount = 0
    var createUserCallCount = 0
    var updateUserCallCount = 0
    var addExperienceCallCount = 0
    var addNemoFruitsCallCount = 0
    var consumePointsCallCount = 0
    var purchaseCheerBuffCallCount = 0

    // MARK: - Protocol Implementation
    func getUser(by playerID: String) async throws -> User? {
        getUserCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return users[playerID]
    }

    func createUser(_ user: User) async throws -> User {
        createUserCallCount += 1
        if shouldThrowError { throw errorToThrow }
        users[user.playerId] = user
        return user
    }

    func updateUser(_ user: User) async throws -> User {
        updateUserCallCount += 1
        if shouldThrowError { throw errorToThrow }
        users[user.playerId] = user

        // 데이터 변경 콜백 호출
        await onDataChanged?()

        return user
    }

    func addExperience(to playerID: String, exp: Int) async throws -> User {
        addExperienceCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard let currentUser = users[playerID] else {
            throw NSError(domain: "MockUserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        let result = Level.addExperience(currentExp: currentUser.exp, expToAdd: exp)
        let newLevel = result.newLevel
        let leveledUp = result.leveledUp
        let levelsGained = result.levelsGained

        var updatedUser = currentUser
        updatedUser.exp = newLevel.currentExp

        if leveledUp {
            updatedUser.remainingPoints += levelsGained * 3
        }

        users[playerID] = updatedUser
        return updatedUser
    }

    func addNemoFruits(to playerID: String, count: Int) async throws -> User {
        addNemoFruitsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var user = users[playerID] else {
            throw NSError(domain: "MockUserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        user.nemoFruit += count
        users[playerID] = user
        return user
    }

    func consumePoints(of playerID: String, points: Int) async throws -> User {
        consumePointsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var user = users[playerID] else {
            throw NSError(domain: "MockUserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        guard user.remainingPoints >= points else {
            throw NSError(domain: "MockUserRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient points"])
        }

        user.remainingPoints -= points
        users[playerID] = user
        return user
    }

    func purchaseCheerBuff(for playerID: String, duration: TimeInterval) async throws -> User {
        purchaseCheerBuffCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var user = users[playerID] else {
            throw NSError(domain: "MockUserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        if user.isCheerBuffActive {
            throw NSError(domain: "MockUserRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cheer buff already active"])
        }

        user.cheerBuffExpiresAt = Date().addingTimeInterval(duration)
        users[playerID] = user
        return user
    }

    // MARK: - Helper Methods
    func reset() {
        users.removeAll()
        shouldThrowError = false
        getUserCallCount = 0
        createUserCallCount = 0
        updateUserCallCount = 0
        addExperienceCallCount = 0
        addNemoFruitsCallCount = 0
        consumePointsCallCount = 0
        purchaseCheerBuffCallCount = 0
    }
}
