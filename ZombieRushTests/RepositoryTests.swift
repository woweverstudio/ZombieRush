//
//  RepositoryTests.swift
//  ZombieRushTests
//
//  Created by Repository Layer Tests - Mock Repositories
//

import Testing
@testable import ZombieRush
import Foundation

// MARK: - MockUserRepository Tests
struct MockUserRepositoryTests {
    private var repository: MockUserRepository!

    init() {
        repository = MockUserRepository()
    }

    @Test("사용자 생성 및 조회 테스트")
    func testCreateAndGetUser() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트유저")

        // When
        let createdUser = try await repository.createUser(user)
        let retrievedUser = try await repository.getUser(by: "test_player")

        // Then
        #expect(createdUser.playerId == "test_player")
        #expect(createdUser.nickname == "테스트유저")
        #expect(retrievedUser?.playerId == "test_player")
        #expect(retrievedUser?.nickname == "테스트유저")
        #expect(repository.createUserCallCount == 1)
        #expect(repository.getUserCallCount == 1)
    }

    @Test("존재하지 않는 사용자 조회 테스트")
    func testGetNonExistentUser() async throws {
        // When
        let user = try await repository.getUser(by: "nonexistent")

        // Then
        #expect(user == nil)
        #expect(repository.getUserCallCount == 1)
    }

    @Test("사용자 업데이트 테스트")
    func testUpdateUser() async throws {
        // Given
        let originalUser = User(playerId: "test_player", nickname: "원래닉네임")
        _ = try await repository.createUser(originalUser)

        var updatedUser = originalUser
        updatedUser.nickname = "새닉네임"

        // When
        let result = try await repository.updateUser(updatedUser)
        let retrievedUser = try await repository.getUser(by: "test_player")

        // Then
        #expect(result.nickname == "새닉네임")
        #expect(retrievedUser?.nickname == "새닉네임")
        #expect(repository.updateUserCallCount == 1)
    }

    @Test("경험치 추가 및 레벨업 테스트")
    func testAddExperience() async throws {
        // Given - 레벨 1 사용자 생성 (0 EXP)
        let user = User(playerId: "test_player", nickname: "테스트", exp: 0)
        _ = try await repository.createUser(user)

        // When - 15 EXP 추가 (레벨업 예상: 0+15=15, 레벨 2)
        let updatedUser = try await repository.addExperience(to: "test_player", exp: 15)

        // Then
        #expect(updatedUser.exp == 15)
        #expect(updatedUser.level == 2)
        #expect(updatedUser.remainingPoints == 3) // 레벨업으로 3포인트 증가
        #expect(repository.addExperienceCallCount == 1)
    }

    @Test("네모열매 추가 테스트")
    func testAddNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        _ = try await repository.createUser(user)

        // When
        let updatedUser = try await repository.addNemoFruits(to: "test_player", count: 5)

        // Then
        #expect(updatedUser.nemoFruit == 15)
        #expect(repository.addNemoFruitsCallCount == 1)
    }

    @Test("네모열매 차감 테스트")
    func testConsumeNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        _ = try await repository.createUser(user)

        // When
        let updatedUser = try await repository.addNemoFruits(to: "test_player", count: -3)

        // Then
        #expect(updatedUser.nemoFruit == 7)
        #expect(repository.addNemoFruitsCallCount == 1)
    }

    @Test("포인트 소비 테스트")
    func testConsumePoints() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", remainingPoints: 10)
        _ = try await repository.createUser(user)

        // When
        let updatedUser = try await repository.consumePoints(of: "test_player", points: 3)

        // Then
        #expect(updatedUser.remainingPoints == 7)
        #expect(repository.consumePointsCallCount == 1)
    }

    @Test("포인트 부족 시 에러 테스트")
    func testConsumePointsInsufficient() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", remainingPoints: 5)
        _ = try await repository.createUser(user)

        // When/Then
        do {
            _ = try await repository.consumePoints(of: "test_player", points: 10)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("Insufficient points"))
        }
        #expect(repository.consumePointsCallCount == 1)
    }

    @Test("네모의 응원 구매 테스트")
    func testPurchaseCheerBuff() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트")
        _ = try await repository.createUser(user)

        // When
        let updatedUser = try await repository.purchaseCheerBuff(for: "test_player", duration: 3600)

        // Then
        #expect(updatedUser.cheerBuffExpiresAt != nil)
        #expect(updatedUser.isCheerBuffActive == true)
        #expect(repository.purchaseCheerBuffCallCount == 1)
    }

    @Test("이미 활성화된 네모의 응원 구매 시 에러 테스트")
    func testPurchaseCheerBuffAlreadyActive() async throws {
        // Given
        var user = User(playerId: "test_player", nickname: "테스트")
        user.cheerBuffExpiresAt = Date().addingTimeInterval(3600) // 이미 활성화됨
        _ = try await repository.createUser(user)

        // When/Then
        do {
            _ = try await repository.purchaseCheerBuff(for: "test_player", duration: 3600)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("Cheer buff already active"))
        }
        #expect(repository.purchaseCheerBuffCallCount == 1)
    }

    @Test("존재하지 않는 사용자에 대한 작업 시 에러 테스트")
    func testOperationsOnNonExistentUser() async throws {
        // When/Then - addExperience
        do {
            _ = try await repository.addExperience(to: "nonexistent", exp: 10)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("User not found"))
        }

        // When/Then - addNemoFruits
        do {
            _ = try await repository.addNemoFruits(to: "nonexistent", count: 5)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("User not found"))
        }

        // When/Then - consumePoints
        do {
            _ = try await repository.consumePoints(of: "nonexistent", points: 5)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("User not found"))
        }

        // When/Then - purchaseCheerBuff
        do {
            _ = try await repository.purchaseCheerBuff(for: "nonexistent", duration: 3600)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("User not found"))
        }
    }

    @Test("에러 시뮬레이션 테스트")
    func testErrorSimulation() async throws {
        // Given
        repository.shouldThrowError = true

        // When/Then - getUser
        do {
            _ = try await repository.getUser(by: "test")
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockUserRepository")
            #expect(error.code == -1)
        }

        // When/Then - createUser
        do {
            let user = User(playerId: "test", nickname: "test")
            _ = try await repository.createUser(user)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockUserRepository")
            #expect(error.code == -1)
        }
    }

    @Test("리셋 기능 테스트")
    func testReset() async throws {
        // Given - 데이터 추가
        let user = User(playerId: "test", nickname: "test")
        _ = try await repository.createUser(user)
        repository.shouldThrowError = true

        // When
        repository.reset()

        // Then
        #expect(repository.users.isEmpty)
        #expect(repository.shouldThrowError == false)
        #expect(repository.getUserCallCount == 0)
        #expect(repository.createUserCallCount == 0)
        #expect(repository.updateUserCallCount == 0)
        #expect(repository.addExperienceCallCount == 0)
        #expect(repository.addNemoFruitsCallCount == 0)
        #expect(repository.consumePointsCallCount == 0)
        #expect(repository.purchaseCheerBuffCallCount == 0)
    }
}

// MARK: - MockStatsRepository Tests
struct MockStatsRepositoryTests {
    private var repository: MockStatsRepository!

    init() {
        repository = MockStatsRepository()
    }

    @Test("스탯 생성 및 조회 테스트")
    func testCreateAndGetStats() async throws {
        // Given
        let stats = Stats(playerId: "test_player", hpRecovery: 5, moveSpeed: 3, energyRecovery: 2, attackSpeed: 1, totemCount: 0)

        // When
        let createdStats = try await repository.createStats(stats)
        let retrievedStats = try await repository.getStats(by: "test_player")

        // Then
        #expect(createdStats.playerId == "test_player")
        #expect(createdStats.hpRecovery == 5)
        #expect(createdStats.moveSpeed == 3)
        #expect(retrievedStats?.playerId == "test_player")
        #expect(retrievedStats?.hpRecovery == 5)
        #expect(retrievedStats?.moveSpeed == 3)
        #expect(repository.createStatsCallCount == 1)
        #expect(repository.getStatsCallCount == 1)
    }

    @Test("존재하지 않는 스탯 조회 테스트")
    func testGetNonExistentStats() async throws {
        // When
        let stats = try await repository.getStats(by: "nonexistent")

        // Then
        #expect(stats == nil)
        #expect(repository.getStatsCallCount == 1)
    }

    @Test("스탯 업데이트 테스트")
    func testUpdateStats() async throws {
        // Given
        let originalStats = Stats(playerId: "test_player", hpRecovery: 1, moveSpeed: 1)
        _ = try await repository.createStats(originalStats)

        var updatedStats = originalStats
        updatedStats.hpRecovery = 10
        updatedStats.moveSpeed = 5

        // When
        let result = try await repository.updateStats(updatedStats)
        let retrievedStats = try await repository.getStats(by: "test_player")

        // Then
        #expect(result.hpRecovery == 10)
        #expect(result.moveSpeed == 5)
        #expect(retrievedStats?.hpRecovery == 10)
        #expect(retrievedStats?.moveSpeed == 5)
        #expect(repository.updateStatsCallCount == 1)
    }

    @Test("HP 회복 스탯 업그레이드 테스트")
    func testUpgradeHpRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", hpRecovery: 3, moveSpeed: 2)
        _ = try await repository.createStats(initialStats)

        // When
        let upgradedStats = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)

        // Then
        #expect(upgradedStats.hpRecovery == 4) // 3 + 1
        #expect(upgradedStats.moveSpeed == 2) // 다른 스탯은 변경되지 않음
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("이동 속도 스탯 업그레이드 테스트")
    func testUpgradeMoveSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", moveSpeed: 1)
        _ = try await repository.createStats(initialStats)

        // When
        let upgradedStats = try await repository.upgradeStat(for: "test_player", statType: .moveSpeed)

        // Then
        #expect(upgradedStats.moveSpeed == 2)
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("에너지 회복 스탯 업그레이드 테스트")
    func testUpgradeEnergyRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", energyRecovery: 0)
        _ = try await repository.createStats(initialStats)

        // When
        let upgradedStats = try await repository.upgradeStat(for: "test_player", statType: .energyRecovery)

        // Then
        #expect(upgradedStats.energyRecovery == 1)
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("공격 속도 스탯 업그레이드 테스트")
    func testUpgradeAttackSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", attackSpeed: 2)
        _ = try await repository.createStats(initialStats)

        // When
        let upgradedStats = try await repository.upgradeStat(for: "test_player", statType: .attackSpeed)

        // Then
        #expect(upgradedStats.attackSpeed == 3)
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("토템 개수 스탯 업그레이드 테스트")
    func testUpgradeTotemCountStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", totemCount: 1)
        _ = try await repository.createStats(initialStats)

        // When
        let upgradedStats = try await repository.upgradeStat(for: "test_player", statType: .totemCount)

        // Then
        #expect(upgradedStats.totemCount == 2)
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("모든 스탯 타입 업그레이드 테스트")
    func testUpgradeAllStatTypes() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player")
        _ = try await repository.createStats(initialStats)

        // When - 모든 스탯 타입 업그레이드
        let hpStats = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)
        let moveStats = try await repository.upgradeStat(for: "test_player", statType: .moveSpeed)
        let energyStats = try await repository.upgradeStat(for: "test_player", statType: .energyRecovery)
        let attackStats = try await repository.upgradeStat(for: "test_player", statType: .attackSpeed)
        let totemStats = try await repository.upgradeStat(for: "test_player", statType: .totemCount)

        // Then
        #expect(hpStats.hpRecovery == 1)
        #expect(moveStats.moveSpeed == 1)
        #expect(energyStats.energyRecovery == 1)
        #expect(attackStats.attackSpeed == 1)
        #expect(totemStats.totemCount == 1)
        #expect(repository.upgradeStatCallCount == 5)
    }

    @Test("존재하지 않는 플레이어의 스탯 업그레이드 시 에러 테스트")
    func testUpgradeStatForNonExistentPlayer() async throws {
        // When/Then
        do {
            _ = try await repository.upgradeStat(for: "nonexistent", statType: .hpRecovery)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch {
            #expect(error.localizedDescription.contains("Stats not found"))
        }
        #expect(repository.upgradeStatCallCount == 1)
    }

    @Test("에러 시뮬레이션 테스트")
    func testErrorSimulation() async throws {
        // Given
        repository.shouldThrowError = true

        // When/Then - getStats
        do {
            _ = try await repository.getStats(by: "test")
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockStatsRepository")
            #expect(error.code == -1)
        }

        // When/Then - createStats
        do {
            let stats = Stats(playerId: "test")
            _ = try await repository.createStats(stats)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockStatsRepository")
            #expect(error.code == -1)
        }

        // When/Then - updateStats
        do {
            let stats = Stats(playerId: "test")
            _ = try await repository.updateStats(stats)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockStatsRepository")
            #expect(error.code == -1)
        }

        // When/Then - upgradeStat
        do {
            _ = try await repository.upgradeStat(for: "test", statType: .hpRecovery)
            #expect(Bool(false), "에러가 발생해야 함")
        } catch let error as NSError {
            #expect(error.domain == "MockStatsRepository")
            #expect(error.code == -1)
        }
    }

    @Test("리셋 기능 테스트")
    func testReset() async throws {
        // Given - 데이터 추가 및 설정 변경
        let stats = Stats(playerId: "test", hpRecovery: 5)
        _ = try await repository.createStats(stats)
        repository.shouldThrowError = true

        // When
        repository.reset()

        // Then
        #expect(repository.stats.isEmpty)
        #expect(repository.shouldThrowError == false)
        #expect(repository.getStatsCallCount == 0)
        #expect(repository.createStatsCallCount == 0)
        #expect(repository.updateStatsCallCount == 0)
        #expect(repository.upgradeStatCallCount == 0)
    }

    @Test("여러 번의 업그레이드 누적 테스트")
    func testMultipleUpgradesAccumulate() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", hpRecovery: 0)
        _ = try await repository.createStats(initialStats)

        // When - 같은 스탯을 여러 번 업그레이드
        _ = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)
        _ = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)
        _ = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)
        let finalStats = try await repository.upgradeStat(for: "test_player", statType: .hpRecovery)

        // Then
        #expect(finalStats.hpRecovery == 4) // 0 + 1 + 1 + 1 + 1
        #expect(repository.upgradeStatCallCount == 4)
    }
}
