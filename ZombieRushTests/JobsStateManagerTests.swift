//
//  JobsStateManagerTests.swift
//  ZombieRushTests
//
//  Created by 김민성 on 2025.
//

import Testing
@testable import ZombieRush

// MARK: - JobsStateManager Tests
struct JobsStateManagerTests {
    private var mockJobsRepository: MockJobsRepository!
    private var stateManager: JobsStateManager!

    init() {
        mockJobsRepository = MockJobsRepository()
        stateManager = JobsStateManager(jobsRepository: mockJobsRepository)
    }

    @Test("새 직업 로드 및 생성 테스트")
    func testLoadOrCreateNewJobs() async throws {
        // When
        await stateManager.loadOrCreateJobs(playerID: "new_player")

        // Then
        #expect(mockJobsRepository.getJobsCallCount == 1)
        #expect(mockJobsRepository.createJobsCallCount == 1)
        #expect(stateManager.currentJobs.playerId == "new_player")
        #expect(stateManager.selectedJobType == .novice) // 기본값은 novice
        #expect(stateManager.currentTab == 0)
        #expect(stateManager.currentJobs.unlockedJobs.count == 1) // novice만 언락됨
        #expect(stateManager.currentJobs.unlockedJobs.contains(.novice))
    }

    @Test("기존 직업 로드 테스트")
    func testLoadExistingJobs() async throws {
        // Given - Mock에 기존 직업 추가
        let existingJobs = Jobs(playerId: "existing_player", fireMage: true, selectedJob: "fire_mage")
        mockJobsRepository.jobs["existing_player"] = existingJobs

        // When
        await stateManager.loadOrCreateJobs(playerID: "existing_player")

        // Then
        #expect(mockJobsRepository.getJobsCallCount == 1)
        #expect(mockJobsRepository.createJobsCallCount == 0) // 기존 데이터가 있으므로 생성하지 않음
        #expect(stateManager.currentJobs.playerId == "existing_player")
        #expect(stateManager.selectedJobType == .fireMage)
        #expect(stateManager.currentJobs.unlockedJobs.count == 2) // novice + fireMage
        #expect(stateManager.currentJobs.unlockedJobs.contains(.novice))
        #expect(stateManager.currentJobs.unlockedJobs.contains(.fireMage))
    }

    @Test("직업 선택 테스트")
    func testSelectJob() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)

        // When - 불 마법사 선택
        await stateManager.selectJob(.fireMage)

        // Then
        #expect(mockJobsRepository.selectJobCallCount == 1)
        #expect(stateManager.selectedJobType == .fireMage)
        #expect(stateManager.selectedJob == "fire_mage")
    }

    @Test("잠금 해제된 직업 선택 테스트")
    func testSelectUnlockedJob() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)

        // When
        await stateManager.selectJob(.fireMage)

        // Then
        #expect(mockJobsRepository.selectJobCallCount == 1)
        #expect(stateManager.selectedJobType == .fireMage)
    }

    @Test("잠금되지 않은 직업 선택 시도 테스트")
    func testSelectLockedJob() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // When - 잠금된 얼음 마법사 선택 시도
        await stateManager.selectJob(.iceMage)

        // Then - 선택되지 않아야 함 (현재 선택된 직업 유지)
        #expect(mockJobsRepository.selectJobCallCount == 1) // 호출은 되었지만 실패
        #expect(stateManager.selectedJobType == .novice) // 여전히 novice
    }

    @Test("직업 잠금 해제 테스트")
    func testUnlockJob() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // When
        await stateManager.unlockJob(.fireMage)

        // Then
        #expect(mockJobsRepository.unlockJobCallCount == 1)
        #expect(stateManager.currentJobs.unlockedJobs.contains(.fireMage))
        #expect(stateManager.currentJobs.unlockedJobs.count == 2)
    }

    @Test("이미 잠금 해제된 직업 다시 해제 테스트")
    func testUnlockAlreadyUnlockedJob() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)

        // When - 이미 잠금 해제된 불 마법사 다시 해제
        await stateManager.unlockJob(.fireMage)

        // Then - Repository는 여전히 호출되지만 상태는 변함 없음
        #expect(mockJobsRepository.unlockJobCallCount == 2)
        #expect(stateManager.currentJobs.unlockedJobs.count == 2)
    }

    @Test("모든 직업 잠금 해제 테스트")
    func testUnlockAllJobs() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // When
        await stateManager.unlockAllJobs()

        // Then
        #expect(mockJobsRepository.updateJobsCallCount == 1) // unlockAllJobs는 updateJobs 한 번 호출
        #expect(stateManager.currentJobs.unlockedJobs.count == JobType.allCases.count)
        #expect(stateManager.currentJobs.unlockedJobs.contains(.novice))
        #expect(stateManager.currentJobs.unlockedJobs.contains(.fireMage))
        #expect(stateManager.currentJobs.unlockedJobs.contains(.iceMage))
        #expect(stateManager.currentJobs.unlockedJobs.contains(.lightningMage))
        #expect(stateManager.currentJobs.unlockedJobs.contains(.darkMage))
    }

    @Test("직업 잠금 해제 여부 확인 테스트")
    func testIsJobUnlocked() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // Then
        #expect(stateManager.currentJobs.unlockedJobs.contains(.novice) == true)  // 기본 잠금 해제
        #expect(stateManager.currentJobs.unlockedJobs.contains(.fireMage) == false)  // 잠금 상태
        #expect(stateManager.currentJobs.unlockedJobs.contains(.iceMage) == false)  // 잠금 상태
    }

    @Test("잠금 해제 후 직업 잠금 해제 여부 확인 테스트")
    func testIsJobUnlockedAfterUnlock() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)

        // Then
        #expect(stateManager.currentJobs.unlockedJobs.contains(.fireMage) == true)
    }

    @Test("직업 스텟 조회 테스트")
    func testJobStats() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // When/Then - novice 기본 스텟 검증
        #expect(stateManager.hp == 100)
        #expect(stateManager.energy == 100)
        #expect(stateManager.move == 10)
        #expect(stateManager.attackSpeed == 10)
    }

    @Test("직업 변경 후 스텟 조회 테스트")
    func testJobStatsAfterSwitch() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)
        await stateManager.selectJob(.fireMage)

        // When/Then - 불 마법사 스텟 검증
        #expect(stateManager.hp == 120)
        #expect(stateManager.energy == 110)
        #expect(stateManager.move == 10)
        #expect(stateManager.attackSpeed == 10)
    }

    @Test("탭 변경 테스트")
    func testTabSwitching() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // When
        stateManager.currentTab = 1

        // Then
        #expect(stateManager.currentTab == 1)
    }

    @Test("직업 초기화 테스트")
    func testResetJobs() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockAllJobs()
        await stateManager.selectJob(.iceMage)

        // When
        stateManager.resetJobs()
        // 약간의 지연을 위해 기다림
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1초

        // Then - 초기 상태로 돌아가야 함
        #expect(mockJobsRepository.updateJobsCallCount == 2) // unlockAllJobs(1) + resetJobs(1)
        #expect(stateManager.selectedJobType == .novice)
        #expect(stateManager.currentJobs.unlockedJobs.count == 1)
        #expect(stateManager.currentJobs.unlockedJobs.contains(.novice))
    }

    @Test("에러 처리 테스트")
    func testErrorHandling() async throws {
        // Given - Mock Repository가 에러를 발생하도록 설정
        mockJobsRepository.shouldThrowError = true

        // When
        await stateManager.loadOrCreateJobs(playerID: "test_player")

        // Then
        #expect(stateManager.currentJobs.playerId == "") // 초기 상태 유지 (load 실패)
        #expect(stateManager.error != nil)
    }

    @Test("직업 정보 출력 테스트")
    func testPrintCurrentJobs() async throws {
        // Given
        await stateManager.loadOrCreateJobs(playerID: "test_player")
        await stateManager.unlockJob(.fireMage)

        // When/Then - printCurrentJobs는 출력만 하므로 호출만 확인
        stateManager.printCurrentJobs()
        #expect(stateManager.currentJobs.playerId == "test_player")
    }
}
