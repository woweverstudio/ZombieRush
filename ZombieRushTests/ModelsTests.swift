//
//  ModelsTests.swift
//  ZombieRushTests
//
//  Created by Domain Model Tests - Level and other Models
//

import Testing
@testable import ZombieRush

// MARK: - Level Model Tests
struct LevelTests {

    @Test("레벨 1 초기화 테스트")
    func testLevel1Initialization() {
        let level = Level(currentExp: 0)
        #expect(level.currentLevel == 1)
        #expect(level.currentExp == 0)
        #expect(level.levelMinExp == 0)
        #expect(level.levelMaxExp == 10)
        #expect(level.expToNextLevel == 10)
        #expect(level.remainingExp == 10)
        #expect(level.progress == 0.0)
        #expect(level.isMaxLevel == false)
    }

    @Test("레벨 계산 테스트 - 다양한 경험치 값")
    func testLevelCalculation() {
        // 레벨 1: 0-9 EXP
        #expect(Level.calculateLevel(from: 0) == 1)
        #expect(Level.calculateLevel(from: 5) == 1)
        #expect(Level.calculateLevel(from: 9) == 1)

        // 레벨 2: 10-29 EXP
        #expect(Level.calculateLevel(from: 10) == 2)
        #expect(Level.calculateLevel(from: 20) == 2)
        #expect(Level.calculateLevel(from: 29) == 2)

        // 레벨 5: 100-149 EXP (Lv.4 max: 100, Lv.5 min: 100)
        #expect(Level.calculateLevel(from: 100) == 5)
        #expect(Level.calculateLevel(from: 115) == 5)
    }

    @Test("최대 레벨 테스트")
    func testMaxLevel() {
        let maxLevelExp = Level.getMinExpForLevel(Level.maxLevel)
        let level = Level(currentExp: maxLevelExp)
        #expect(level.currentLevel == Level.maxLevel)
        #expect(level.isMaxLevel == true) // 최대 레벨에 도달하면 isMaxLevel = true
        #expect(level.progress == 1.0) // 최대 레벨에서는 progress = 1.0
        #expect(level.remainingExp == 0) // 최대 레벨에서는 더 이상 남은 EXP가 없음
    }

    @Test("경험치 요구량 계산 테스트")
    func testExpRequiredForLevel() {
        // Lv.1-10: 10씩 증가
        #expect(Level.getExpRequiredForLevel(1) == 10)
        #expect(Level.getExpRequiredForLevel(5) == 50)
        #expect(Level.getExpRequiredForLevel(10) == 100)

        // Lv.11-20: 20씩 증가
        #expect(Level.getExpRequiredForLevel(11) == 120)
        #expect(Level.getExpRequiredForLevel(15) == 200)
        #expect(Level.getExpRequiredForLevel(20) == 300)

        // Lv.21-30: 30씩 증가
        #expect(Level.getExpRequiredForLevel(21) == 330)
        #expect(Level.getExpRequiredForLevel(25) == 450)
        #expect(Level.getExpRequiredForLevel(30) == 600)

        // Lv.31+: 50씩 증가
        #expect(Level.getExpRequiredForLevel(31) == 650)
        #expect(Level.getExpRequiredForLevel(50) == 1600)
    }

    @Test("최소/최대 경험치 계산 테스트")
    func testMinMaxExpForLevel() {
        // 레벨 1: 0-9
        #expect(Level.getMinExpForLevel(1) == 0)
        #expect(Level.getMaxExpForLevel(1) == 10)

        // 레벨 2: 10-29
        #expect(Level.getMinExpForLevel(2) == 10)
        #expect(Level.getMaxExpForLevel(2) == 30)

        // 레벨 3: 30-59
        #expect(Level.getMinExpForLevel(3) == 30)
        #expect(Level.getMaxExpForLevel(3) == 60)
    }

    @Test("경험치 추가 및 레벨업 테스트")
    func testAddExperience() {
        // 레벨 1에서 경험치 15 추가 (레벨업 예상)
        let result = Level.addExperience(currentExp: 5, expToAdd: 15)
        #expect(result.newLevel.currentLevel == 2)
        #expect(result.leveledUp == true)
        #expect(result.levelsGained == 1)

        // 레벨 2에서 경험치 5 추가 (레벨업 없음)
        let result2 = Level.addExperience(currentExp: 15, expToAdd: 5)
        #expect(result2.newLevel.currentLevel == 2)
        #expect(result2.leveledUp == false)
        #expect(result2.levelsGained == 0)

        // 다중 레벨업 테스트
        let result3 = Level.addExperience(currentExp: 0, expToAdd: 60)
        #expect(result3.newLevel.currentLevel == 4) // 10+20+30 = 60 EXP
        #expect(result3.leveledUp == true)
        #expect(result3.levelsGained == 3)
    }

    @Test("진행률 계산 테스트")
    func testProgressCalculation() {
        // 레벨 1, 5/10 EXP = 50%
        let level1 = Level(currentExp: 5)
        #expect(level1.progress == 0.5)
        #expect(level1.progressPercentage == "50%")

        // 레벨 2, 25 EXP = 75% (레벨 2 범위: 10-29, 현재: 25, 진행: (25-10)/(30-10) = 15/20 = 0.75)
        let level2 = Level(currentExp: 25)
        #expect(level2.progress == 0.75)
        #expect(level2.progressPercentage == "75%")

        // 최대 레벨
        let maxLevel = Level(currentExp: Level.getMinExpForLevel(Level.maxLevel))
        #expect(maxLevel.progress == 1.0) // 최대 레벨에서는 progress = 1.0 (완료됨)
        #expect(maxLevel.progressPercentage == "100%")
    }

    @Test("레벨 정보 문자열 테스트")
    func testLevelInfoString() {
        let level1 = Level(currentExp: 5)
        #expect(level1.levelInfo == "Lv.1 (50%)")

        let maxLevel = Level(currentExp: Level.getMinExpForLevel(Level.maxLevel))
        #expect(maxLevel.levelInfo == "Lv.\(Level.maxLevel) (MAX)")
    }
}
