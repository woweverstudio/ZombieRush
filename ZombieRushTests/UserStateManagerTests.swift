//
//  UserStateManagerTests.swift
//  ZombieRushTests
//
//  Created by 김민성 on 2025.
//

import Testing
@testable import ZombieRush

// MARK: - UserStateManager Tests
struct UserStateManagerTests {
    private var stateManager: UserStateManager!
    private var mockUserRepository: MockUserRepository!
    private var mockSpiritsRepository: MockSpiritsRepository! // 임시 Mock (TODO: MockSpiritsRepository 생성)

    init() {
        // Mock Repository들 직접 생성
        mockUserRepository = MockUserRepository()
        mockSpiritsRepository = MockSpiritsRepository() // 임시: 실제로는 MockSpiritsRepository 사용 필요

        // StateManager 직접 생성 (Repository 주입)
        stateManager = UserStateManager(
            userRepository: mockUserRepository,
            spiritsRepository: mockSpiritsRepository
        )
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
        #expect(mockUserRepository.createUserCallCount == 1)
        #expect(mockUserRepository.getUserCallCount == 1)
    }

    @Test("기존 사용자 로드 테스트")
    func testLoadExistingUser() async throws {
        // Given - Mock에 기존 사용자 추가
        let existingUser = User(playerId: "existing_player", nickname: "기존유저", exp: 50, nemoFruit: 10, remainingPoints: 5)
        mockUserRepository.users["existing_player"] = existingUser

        // When
        await stateManager.loadOrCreateUser(playerID: "existing_player", nickname: "업데이트된닉네임")

        // Then
        #expect(stateManager.currentUser?.playerId == "existing_player")
        #expect(stateManager.currentUser?.nickname == "업데이트된닉네임") // 닉네임이 업데이트되어야 함
        #expect(stateManager.currentUser?.exp == 50)
        #expect(stateManager.currentUser?.nemoFruit == 10)
        #expect(stateManager.currentUser?.remainingPoints == 5)
        #expect(mockUserRepository.getUserCallCount == 1)
        #expect(mockUserRepository.createUserCallCount == 0)
        #expect(mockUserRepository.updateUserCallCount == 1) // 닉네임 업데이트로 인해
    }

    @Test("계산된 프로퍼티 테스트")
    func testComputedProperties() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", exp: 25, nemoFruit: 15, remainingPoints: 8)
        mockUserRepository.users["test_player"] = user
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
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When - 8 EXP 추가 (총 13 EXP, 레벨 2)
        let result = await stateManager.addExperience(8)

        // Then
        #expect(result.leveledUp == true)
        #expect(result.levelsGained == 1)
        #expect(stateManager.currentUser?.exp == 13)
        #expect(stateManager.currentUser?.remainingPoints == 3) // 레벨업으로 3포인트 증가
        #expect(stateManager.level?.currentLevel == 2)
        #expect(mockUserRepository.addExperienceCallCount == 1)
    }

    @Test("네모열매 추가 테스트")
    func testAddNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.addNemoFruits(5)

        // Then
        #expect(success == true)
        #expect(stateManager.nemoFruits == 15)
        #expect(mockUserRepository.addNemoFruitsCallCount == 1)
    }

    @Test("네모열매 소비 테스트")
    func testConsumeNemoFruits() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", nemoFruit: 10)
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.consumeNemoFruits(3)

        // Then
        #expect(success == true)
        #expect(stateManager.nemoFruits == 7)
        #expect(mockUserRepository.addNemoFruitsCallCount == 1)
    }

    @Test("포인트 소비 테스트")
    func testConsumeRemainingPoints() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", remainingPoints: 10)
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.consumeRemainingPoints(4)

        // Then
        #expect(success == true)
        #expect(stateManager.remainingPoints == 6)
        #expect(mockUserRepository.consumePointsCallCount == 1)
    }

    @Test("네모의 응원 구매 테스트")
    func testPurchaseCheerBuff() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트")
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When
        let success = await stateManager.purchaseCheerBuff()

        // Then
        #expect(success == true)
        #expect(stateManager.isCheerBuffActive == true)
        #expect(stateManager.currentUser?.cheerBuffExpiresAt != nil)
        #expect(mockUserRepository.purchaseCheerBuffCallCount == 1)
    }

    @Test("레벨업 가능 여부 확인 테스트")
    func testCanLevelUp() async throws {
        // Given - 레벨 1, 9 EXP (레벨업까지 1 EXP 남음)
        let user = User(playerId: "test_player", nickname: "테스트", exp: 9)
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // Then
        #expect(stateManager.canLevelUp(withAdditionalExp: 1) == true)  // 1 EXP로 레벨업 가능
        #expect(stateManager.canLevelUp(withAdditionalExp: 0) == false) // 0 EXP로는 레벨업 불가
    }

    @Test("사용자 업데이트 테스트")
    func testUpdateUser() async throws {
        // Given
        let user = User(playerId: "test_player", nickname: "테스트", exp: 10)
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        var updatedUser = user
        updatedUser.exp = 20

        // When
        await stateManager.updateUser(updatedUser)

        // Then
        #expect(stateManager.currentUser?.exp == 20)
        #expect(mockUserRepository.updateUserCallCount == 1)
    }

    @Test("에러 처리 테스트")
    func testErrorHandling() async throws {
        // Given - 에러가 발생하도록 설정
        mockUserRepository.shouldThrowError = true

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
        mockUserRepository.users["test_player"] = user
        await stateManager.loadOrCreateUser(playerID: "test_player", nickname: "테스트")

        // When/Then - printCurrentUser는 출력만 하므로 호출만 확인
        stateManager.printCurrentUser()
        #expect(stateManager.currentUser != nil)
    }
}
