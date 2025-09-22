//
//  StatsStateManagerTests.swift
//  ZombieRushTests
//
//  Created by 김민성 on 2025.
//

import Testing
@testable import ZombieRush

// MARK: - StatsStateManager Tests
struct StatsStateManagerTests {
    private var mockStatsRepository: MockStatsRepository!
    private var stateManager: StatsStateManager!

    init() {
        mockStatsRepository = MockStatsRepository()
        stateManager = StatsStateManager(statsRepository: mockStatsRepository)
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
        #expect(mockStatsRepository.createStatsCallCount == 1)
        #expect(mockStatsRepository.getStatsCallCount == 1)
    }

    @Test("기존 스탯 로드 테스트")
    func testLoadExistingStats() async throws {
        // Given - Mock에 기존 스탯 추가
        let existingStats = Stats(playerId: "existing_player", hpRecovery: 5, moveSpeed: 3, energyRecovery: 2, attackSpeed: 4, totemCount: 1)
        mockStatsRepository.stats["existing_player"] = existingStats

        // When
        await stateManager.loadOrCreateStats(playerID: "existing_player")

        // Then
        #expect(stateManager.currentStats?.playerId == "existing_player")
        #expect(stateManager.currentStats?.hpRecovery == 5)
        #expect(stateManager.currentStats?.moveSpeed == 3)
        #expect(stateManager.currentStats?.energyRecovery == 2)
        #expect(stateManager.currentStats?.attackSpeed == 4)
        #expect(stateManager.currentStats?.totemCount == 1)
        #expect(mockStatsRepository.getStatsCallCount == 1)
        #expect(mockStatsRepository.createStatsCallCount == 0)
    }

    @Test("HP 회복 스탯 업그레이드 테스트")
    func testUpgradeHpRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", hpRecovery: 2, moveSpeed: 1)
        mockStatsRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.hpRecovery)

        // Then
        #expect(stateManager.currentStats?.hpRecovery == 3) // 2 + 1
        #expect(stateManager.currentStats?.moveSpeed == 1) // 다른 스탯은 변경되지 않음
        #expect(mockStatsRepository.upgradeStatCallCount == 1)
    }

    @Test("이동 속도 스탯 업그레이드 테스트")
    func testUpgradeMoveSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", moveSpeed: 3)
        mockStatsRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.moveSpeed)

        // Then
        #expect(stateManager.currentStats?.moveSpeed == 4)
        #expect(mockStatsRepository.upgradeStatCallCount == 1)
    }

    @Test("에너지 회복 스탯 업그레이드 테스트")
    func testUpgradeEnergyRecoveryStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", energyRecovery: 1)
        mockStatsRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.energyRecovery)

        // Then
        #expect(stateManager.currentStats?.energyRecovery == 2)
        #expect(mockStatsRepository.upgradeStatCallCount == 1)
    }

    @Test("공격 속도 스탯 업그레이드 테스트")
    func testUpgradeAttackSpeedStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", attackSpeed: 2)
        mockStatsRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.attackSpeed)

        // Then
        #expect(stateManager.currentStats?.attackSpeed == 3)
        #expect(mockStatsRepository.upgradeStatCallCount == 1)
    }

    @Test("토템 개수 스탯 업그레이드 테스트")
    func testUpgradeTotemCountStat() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player", totemCount: 0)
        mockStatsRepository.stats["test_player"] = initialStats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When
        await stateManager.upgradeStat(.totemCount)

        // Then
        #expect(stateManager.currentStats?.totemCount == 1)
        #expect(mockStatsRepository.upgradeStatCallCount == 1)
    }

    @Test("모든 스탯 타입 업그레이드 테스트")
    func testUpgradeAllStatTypes() async throws {
        // Given
        let initialStats = Stats(playerId: "test_player")
        mockStatsRepository.stats["test_player"] = initialStats
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
        #expect(mockStatsRepository.upgradeStatCallCount == 5)
    }

    @Test("로그아웃 테스트")
    func testLogout() async throws {
        // Given - 스탯 데이터 로드
        let stats = Stats(playerId: "test_player", hpRecovery: 5, moveSpeed: 3)
        mockStatsRepository.stats["test_player"] = stats
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
        mockStatsRepository.shouldThrowError = true

        // When - 스탯이 있는 상태에서 업그레이드 시도 (Repository에서 에러 발생)
        await stateManager.upgradeStat(.hpRecovery)

        // Then
        #expect(stateManager.currentStats != nil) // 스탯은 여전히 존재
        #expect(stateManager.error != nil) // 에러가 설정됨
        #expect(mockStatsRepository.upgradeStatCallCount == 1) // Repository가 호출됨
    }

    @Test("스탯 로드 시 에러 처리 테스트")
    func testLoadStatsError() async throws {
        // Given - 에러가 발생하도록 설정
        mockStatsRepository.shouldThrowError = true

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
        mockStatsRepository.stats["test_player"] = stats
        await stateManager.loadOrCreateStats(playerID: "test_player")

        // When/Then - printCurrentStats는 출력만 하므로 호출만 확인
        stateManager.printCurrentStats()
        #expect(stateManager.currentStats != nil)
    }
}
