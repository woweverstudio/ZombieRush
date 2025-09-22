//
//  StateManagerTests.swift
//  ZombieRushTests
//
//  Created by State Management Layer Tests - StateManagers
//

import Testing
@testable import ZombieRush

// MARK: - UserStateManager Tests
struct UserStateManagerTests {
    private var mockRepository: MockUserRepository!
    private var stateManager: UserStateManager!

    init() {
        mockRepository = MockUserRepository()
        stateManager = UserStateManager(userRepository: mockRepository)
    }

    @Test("새 사용자 로드 및 생성 테스트")
    func testLoadOrCreateNewUser() async throws {
        // When
        await stateManager.loadOrCreateUser(playerID: "new_player", nickname: "새로운유저")

        // Then
        #expect(stateManager.currentUser?.playerId == "new_player")
        #expect(stateManager.currentUser?.nickname == "새로운유저")
        #expect(stateManager.currentUser?.exp == 0)
        #expect(stateManager.currentUser?.nemoFruit == 0)
        #expect(stateManager.currentUser?.remainingPoints == 0)
        #expect(mockRepository.createUserCallCount == 1)
        #expect(mockRepository.getUserCallCount == 1)
    }

    @Test("기존 사용자 로드 테스트")
    func testLoadExistingUser() async throws {
        // Given - Mock에 기존 사용자 추가
        let existingUser = User(playerId: "existing_player", nickname: "기존유저", exp: 50, nemoFruit: 10, remainingPoints: 5)
        mockRepository.users["existing_player"] = existingUser

        // When
        await stateManager.loadOrCreateUser(playerID: "existing_player", nickname: "업데이트된닉네임")

        // Then
        #expect(stateManager.currentUser?.playerId == "existing_player")
        #expect(stateManager.currentUser?.nickname == "업데이트된닉네임") // 닉네임이 업데이트되어야 함
        #expect(stateManager.currentUser?.exp == 50)
        #expect(stateManager.currentUser?.nemoFruit == 10)
        #expect(stateManager.currentUser?.remainingPoints == 5)
        #expect(mockRepository.getUserCallCount == 1)
        #expect(mockRepository.createUserCallCount == 0)
        #expect(mockRepository.updateUserCallCount == 1) // 닉네임 업데이트로 인해
    }

    @Test("계산된 프로퍼티 테스트")
    func testComputedProperties() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", exp: 25, nemoFruit: 15, remainingPoints: 8)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // Then
        #expect(stateManager.nickname == "테스트")
        #expect(stateManager.experience == 25)
        #expect(stateManager.remainingPoints == 8)
        #expect(stateManager.nemoFruits == 15)
        #expect(stateManager.level?.currentLevel == 2) // 25 EXP = 레벨 2 (10-29 범위)
        #expect(stateManager.levelProgress == 0.75) // 레벨 2에서 15/20 = 0.75
        #expect(stateManager.expToNextLevel == 5) // 레벨 2 최대 30, 현재 25, 남은 5
    }

    @Test("경험치 추가 및 레벨업 테스트")
    func testAddExperience() async throws {
        // Given - 레벨 1 사용자
        let user = User(playerId: "test_player", nickname: "테스트", exp: 5)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When - 8 EXP 추가 (총 13 EXP, 레벨 2)
        let result = await stateManager.addExperience(8)

        // Then
        #expect(result.leveledUp == true)
        #expect(result.levelsGained == 1)
        #expect(stateManager.currentUser?.exp == 13)
        #expect(stateManager.currentUser?.remainingPoints == 3) // 레벨업으로 3포인트 증가
        #expect(stateManager.level?.currentLevel == 2)
        #expect(mockRepository.addExperienceCallCount == 1)
    }

    @Test("네모열매 추가 테스트")
    func testAddNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.addNemoFruits(5)

        // Then
        #expect(success == true)
        #expect(stateManager.nemoFruits == 15)
        #expect(mockRepository.addNemoFruitsCallCount == 1)
    }

    @Test("네모열매 소비 테스트")
    func testConsumeNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.consumeNemoFruits(3)

        // Then
        #expect(success == true)
        #expect(stateManager.nemoFruits == 7)
        #expect(mockRepository.addNemoFruitsCallCount == 1)
    }

    @Test("포인트 소비 테스트")
    func testConsumeRemainingPoints() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", remainingPoints: 10)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.consumeRemainingPoints(4)

        // Then
        #expect(success == true)
        #expect(stateManager.remainingPoints == 6)
        #expect(mockRepository.consumePointsCallCount == 1)
    }

    @Test("네모의 응원 구매 테스트")
    func testPurchaseCheerBuff() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트")
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.purchaseCheerBuff()

        // Then
        #expect(success == true)
        #expect(stateManager.isCheerBuffActive == true)
        #expect(stateManager.currentUser?.cheerBuffExpiresAt != nil)
        #expect(mockRepository.purchaseCheerBuffCallCount == 1)
    }

    @Test("레벨업 가능 여부 확인 테스트")
    func testCanLevelUp() async throws {
        // Given - 레벨 1, 9 EXP (레벨업까지 1 EXP 남음)
        let user = User(playerId: "test_player", nickname: "테스트", exp: 9)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // Then
        #expect(stateManager.canLevelUp(withAdditionalExp: 1) == true)  // 1 EXP로 레벨업 가능
        #expect(stateManager.canLevelUp(withAdditionalExp: 0) == false) // 0 EXP로는 레벨업 불가
    }

    @Test("사용자 업데이트 테스트")
    func testUpdateUser() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", exp: 10)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        var updatedUser = user
        updatedUser.exp = 20

        // When
        await stateManager.updateUser(updatedUser)

        // Then
        #expect(stateManager.currentUser?.exp == 20)
        #expect(mockRepository.updateUserCallCount == 1)
    }

    @Test("에러 처리 테스트")
    func testErrorHandling() async throws {
        // Given - 에러가 발생하도록 설정
        mockRepository.shouldThrowError = true

        // When
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // Then
        #expect(stateManager.currentUser == nil)
        #expect(stateManager.error != nil)
    }

    @Test("사용자 정보 출력 테스트")
    func testPrintCurrentUser() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", exp: 25, nemoFruit: 10, remainingPoints: 5)
        mockRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When/Then - printCurrentUser는 출력만 하므로 호출만 확인
        stateManager.printCurrentUser()
        #expect(stateManager.currentUser != nil)
    }
}

// MARK: - StatsStateManager Tests
struct StatsStateManagerTests {
    private var mockRepository: MockStatsRepository!
    private var stateManager: StatsStateManager!

    init() {
        mockRepository = MockStatsRepository()
        stateManager = StatsStateManager(statsRepository: mockRepository)
    }

    @Test("새 스탯 로드 및 생성 테스트")
    func testLoadOrCreateNewStats() async throws {
        // When
        await stateManager.loadOrCreateStats(playerID: "new_player")

        // Then
        #expect(stateManager.currentStats?.playerId == "new_player")
        #expect(stateManager.currentStats?.hpRecovery == 0)
        #expect(stateManager.currentStats?.moveSpeed == 0)
        #expect(stateManager.currentStats?.energyRecovery == 0)
        #expect(stateManager.currentStats?.attackSpeed == 0)
        #expect(stateManager.currentStats?.totemCount == 0)
        #expect(mockRepository.createStatsCallCount == 1)
        #expect(mockRepository.getStatsCallCount == 1)
    }

    @Test("기존 스탯 로드 테스트")
    func testLoadExistingStats() async throws {
        // Given - Mock에 기존 스탯 추가
        let existingStats = Stats(playerId: "existing_player", hpRecovery: 5, moveSpeed: 3, energyRecovery: 2, attackSpeed: 4, totemCount: 1)
        mockRepository.stats["existing_player"] = existingStats

        // When
        await stateManager.loadOrCreateStats(playerID: "existing_player")

        // Then
        #expect(stateManager.currentStats?.playerId == "existing_player")
        #expect(stateManager.currentStats?.hpRecovery == 5)
        #expect(stateManager.currentStats?.moveSpeed == 3)
        #expect(stateManager.currentStats?.energyRecovery == 2)
        #expect(stateManager.currentStats?.attackSpeed == 4)
        #expect(stateManager.currentStats?.totemCount == 1)
        #expect(mockRepository.getStatsCallCount == 1)
        #expect(mockRepository.createStatsCallCount == 0)
    }

    @Test("HP 회복 스탯 업그레이드 테스트")
    func testUpgradeHpRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", hpRecovery: 2, moveSpeed: 1)
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.hpRecovery)

        // Then
        #expect(stateManager.currentStats?.hpRecovery == 3) // 2 + 1
        #expect(stateManager.currentStats?.moveSpeed == 1) // 다른 스탯은 변경되지 않음
        #expect(mockRepository.upgradeStatCallCount == 1)
    }

    @Test("이동 속도 스탯 업그레이드 테스트")
    func testUpgradeMoveSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", moveSpeed: 3)
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.moveSpeed)

        // Then
        #expect(stateManager.currentStats?.moveSpeed == 4)
        #expect(mockRepository.upgradeStatCallCount == 1)
    }

    @Test("에너지 회복 스탯 업그레이드 테스트")
    func testUpgradeEnergyRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", energyRecovery: 1)
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.energyRecovery)

        // Then
        #expect(stateManager.currentStats?.energyRecovery == 2)
        #expect(mockRepository.upgradeStatCallCount == 1)
    }

    @Test("공격 속도 스탯 업그레이드 테스트")
    func testUpgradeAttackSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", attackSpeed: 2)
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.attackSpeed)

        // Then
        #expect(stateManager.currentStats?.attackSpeed == 3)
        #expect(mockRepository.upgradeStatCallCount == 1)
    }

    @Test("토템 개수 스탯 업그레이드 테스트")
    func testUpgradeTotemCountStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", totemCount: 0)
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.totemCount)

        // Then
        #expect(stateManager.currentStats?.totemCount == 1)
        #expect(mockRepository.upgradeStatCallCount == 1)
    }

    @Test("모든 스탯 타입 업그레이드 테스트")
    func testUpgradeAllStatTypes() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player")
        mockRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When - 모든 스탯 타입 업그레이드
        await stateManager.upgradeStat(.hpRecovery)
        await stateManager.upgradeStat(.moveSpeed)
        await stateManager.upgradeStat(.energyRecovery)
        await stateManager.upgradeStat(.attackSpeed)
        await stateManager.upgradeStat(.totemCount)

        // Then
        #expect(stateManager.currentStats?.hpRecovery == 1)
        #expect(stateManager.currentStats?.moveSpeed == 1)
        #expect(stateManager.currentStats?.energyRecovery == 1)
        #expect(stateManager.currentStats?.attackSpeed == 1)
        #expect(stateManager.currentStats?.totemCount == 1)
        #expect(mockRepository.upgradeStatCallCount == 5)
    }

    @Test("로그아웃 테스트")
    func testLogout() async throws {
        // Given - 스탯 데이터 로드
        let stats = Stats(playerId: "test_player", hpRecovery: 5, moveSpeed: 3)
        mockRepository.stats["test_player"] = stats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        stateManager.logout()

        // Then
        #expect(stateManager.currentStats == nil)
        #expect(stateManager.error == nil)
    }

    @Test("스탯 업그레이드 시 에러 처리 테스트")
    func testUpgradeStatError() async throws {
        // Given - 스탯 로드 후 Repository 에러 설정
        await stateManager.loadOrCreateStats(playerID: "test_player")
        mockRepository.shouldThrowError = true

        // When - 스탯이 있는 상태에서 업그레이드 시도 (Repository에서 에러 발생)
        await stateManager.upgradeStat(.hpRecovery)

        // Then
        #expect(stateManager.currentStats != nil) // 스탯은 여전히 존재
        #expect(stateManager.error != nil) // 에러가 설정됨
        #expect(mockRepository.upgradeStatCallCount == 1) // Repository가 호출됨
    }

    @Test("스탯 로드 시 에러 처리 테스트")
    func testLoadStatsError() async throws {
        // Given - 에러가 발생하도록 설정
        mockRepository.shouldThrowError = true

        // When
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // Then
        #expect(stateManager.currentStats == nil)
        #expect(stateManager.error != nil)
    }

    @Test("스탯 정보 출력 테스트")
    func testPrintCurrentStats() async throws {
        // Given
        let stats = Stats(playerId: "test_player", hpRecovery: 3, moveSpeed: 2, energyRecovery: 1, attackSpeed: 4, totemCount: 2)
        mockRepository.stats["test_player"] = stats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When/Then - printCurrentStats는 출력만 하므로 호출만 확인
        stateManager.printCurrentStats()
        #expect(stateManager.currentStats != nil)
    }

    @Test("기본 생성자 사용 시 정상적으로 초기화되는지 테스트")
    func testDefaultConstructor() {
        // When
        let defaultStateManager = StatsStateManager()

        // Then - StateManager가 정상적으로 초기화되었고 기본 상태인지 확인
        #expect(defaultStateManager.currentStats == nil)
        #expect(defaultStateManager.isLoading == false)
        #expect(defaultStateManager.error == nil)
    }
}
