//
//  SpiritsStateManagerTests.swift
//  ZombieRushTests
//
//  Created by 김민성 on 2025.
//

import Testing
@testable import ZombieRush

// MARK: - SpiritsStateManager Tests
struct SpiritsStateManagerTests {
    private var mockSpiritsRepository: MockSpiritsRepository!
    private var stateManager: SpiritsStateManager!

    init() {
        mockSpiritsRepository = MockSpiritsRepository()
        stateManager = SpiritsStateManager(spiritsRepository: mockSpiritsRepository)
    }

    @Test("새 정령 로드 및 생성 테스트")
    func testLoadOrCreateNewSpirits() async throws {
        // When
        await stateManager.loadOrCreateSpirits(playerID: "new_player")

        // Then
        #expect(mockSpiritsRepository.getSpiritsCallCount == 1)
        #expect(mockSpiritsRepository.createSpiritsCallCount == 1)
        #expect(stateManager.currentSpirits?.playerId == "new_player")
        #expect(stateManager.currentSpirits?.fire == 0)
        #expect(stateManager.currentSpirits?.ice == 0)
        #expect(stateManager.currentSpirits?.lightning == 0)
        #expect(stateManager.currentSpirits?.dark == 0)
        #expect(stateManager.currentSpirits?.totalCount == 0)
    }

    @Test("기존 정령 로드 테스트")
    func testLoadExistingSpirits() async throws {
        // Given - Mock에 기존 정령 추가
        let existingSpirits = Spirits(playerId: "existing_player", fire: 5, ice: 3, lightning: 2, dark: 4)
        mockSpiritsRepository.spirits["existing_player"] = existingSpirits

        // When
        await stateManager.loadOrCreateSpirits(playerID: "existing_player")

        // Then
        #expect(mockSpiritsRepository.getSpiritsCallCount == 1)
        #expect(mockSpiritsRepository.createSpiritsCallCount == 0) // 기존 데이터가 있으므로 생성하지 않음
        #expect(stateManager.currentSpirits?.playerId == "existing_player")
        #expect(stateManager.currentSpirits?.fire == 5)
        #expect(stateManager.currentSpirits?.ice == 3)
        #expect(stateManager.currentSpirits?.lightning == 2)
        #expect(stateManager.currentSpirits?.dark == 4)
        #expect(stateManager.currentSpirits?.totalCount == 14)
    }

    @Test("정령 추가 테스트 - 불 정령")
    func testAddFireSpirit() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.addSpirit(.fire, count: 3)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 1)
        #expect(stateManager.currentSpirits?.fire == 3)
        #expect(stateManager.currentSpirits?.totalCount == 3)
    }

    @Test("정령 추가 테스트 - 얼음 정령")
    func testAddIceSpirit() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.addSpirit(.ice, count: 2)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 1)
        #expect(stateManager.currentSpirits?.ice == 2)
        #expect(stateManager.currentSpirits?.totalCount == 2)
    }

    @Test("정령 추가 테스트 - 번개 정령")
    func testAddLightningSpirit() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.addSpirit(.lightning, count: 4)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 1)
        #expect(stateManager.currentSpirits?.lightning == 4)
        #expect(stateManager.currentSpirits?.totalCount == 4)
    }

    @Test("정령 추가 테스트 - 어둠 정령")
    func testAddDarkSpirit() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.addSpirit(.dark, count: 1)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 1)
        #expect(stateManager.currentSpirits?.dark == 1)
        #expect(stateManager.currentSpirits?.totalCount == 1)
    }

    @Test("여러 정령 동시 추가 테스트")
    func testAddMultipleSpirits() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.addSpirit(.fire, count: 2)
        await stateManager.addSpirit(.ice, count: 3)
        await stateManager.addSpirit(.lightning, count: 1)
        await stateManager.addSpirit(.dark, count: 4)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 4)
        #expect(stateManager.currentSpirits?.fire == 2)
        #expect(stateManager.currentSpirits?.ice == 3)
        #expect(stateManager.currentSpirits?.lightning == 1)
        #expect(stateManager.currentSpirits?.dark == 4)
        #expect(stateManager.currentSpirits?.totalCount == 10)
    }

    @Test("정령 감소 테스트")
    func testRemoveSpirits() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")
        await stateManager.addSpirit(.fire, count: 5)

        // When - 음수로 추가하여 감소 효과
        await stateManager.addSpirit(.fire, count: -2)

        // Then
        #expect(mockSpiritsRepository.addSpiritCallCount == 2)
        #expect(stateManager.currentSpirits?.fire == 3)
        #expect(stateManager.currentSpirits?.totalCount == 3)
    }

    @Test("모든 정령 증가 테스트")
    func testIncreaseAllSpirits() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // When
        await stateManager.increaseAllSpirits(amount: 2)

        // Then
        #expect(mockSpiritsRepository.updateSpiritsCallCount == 1) // increaseAllSpirits는 updateSpirits 호출
        #expect(stateManager.currentSpirits?.fire == 2)
        #expect(stateManager.currentSpirits?.ice == 2)
        #expect(stateManager.currentSpirits?.lightning == 2)
        #expect(stateManager.currentSpirits?.dark == 2)
        #expect(stateManager.currentSpirits?.totalCount == 8)
    }

    @Test("정령 초기화 테스트")
    func testResetSpirits() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")
        await stateManager.addSpirit(.fire, count: 3)
        await stateManager.addSpirit(.ice, count: 2)
        await stateManager.addSpirit(.lightning, count: 1)
        await stateManager.addSpirit(.dark, count: 4)

        // When
        stateManager.resetSpirits()
        // 약간의 지연을 위해 기다림
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1초

        // Then
        #expect(mockSpiritsRepository.updateSpiritsCallCount == 1) // resetSpirits는 updateSpirits 호출
        #expect(stateManager.currentSpirits?.fire == 0)
        #expect(stateManager.currentSpirits?.ice == 0)
        #expect(stateManager.currentSpirits?.lightning == 0)
        #expect(stateManager.currentSpirits?.dark == 0)
        #expect(stateManager.currentSpirits?.totalCount == 0)
    }

    @Test("정령 수량 조회 테스트")
    func testSpiritCounts() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")
        await stateManager.addSpirit(.fire, count: 3)
        await stateManager.addSpirit(.ice, count: 2)

        // When/Then - Spirits 모델의 프로퍼티로 직접 접근
        #expect(stateManager.currentSpirits?.fire == 3)
        #expect(stateManager.currentSpirits?.ice == 2)
        #expect(stateManager.currentSpirits?.lightning == 0)
        #expect(stateManager.currentSpirits?.dark == 0)
        #expect(stateManager.currentSpirits?.totalCount == 5)
    }

    @Test("에러 처리 테스트")
    func testErrorHandling() async throws {
        // Given - 에러가 발생하도록 설정
        mockSpiritsRepository.shouldThrowError = true

        // When
        await stateManager.loadOrCreateSpirits(playerID: "test_player")

        // Then
        #expect(stateManager.currentSpirits == nil)
        #expect(stateManager.error != nil)
    }

    @Test("정령 정보 출력 테스트")
    func testPrintCurrentSpirits() async throws {
        // Given
        await stateManager.loadOrCreateSpirits(playerID: "test_player")
        await stateManager.addSpirit(.fire, count: 2)
        await stateManager.addSpirit(.ice, count: 1)

        // When/Then - printCurrentSpirits는 출력만 하므로 호출만 확인
        stateManager.printCurrentSpirits()
        #expect(stateManager.currentSpirits != nil)
    }
}
