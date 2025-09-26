//
//  Level.swift
//  ZombieRush
//
//  Created by Level Model with Experience Management
//

import Foundation

/// 레벨과 경험치 관리 모델
struct Level {
    /// 현재 레벨
    let currentLevel: Int

    /// 현재 경험치
    let currentExp: Int

    /// 현재 레벨의 최소 경험치
    let levelMinExp: Int

    /// 현재 레벨의 최대 경험치 (다음 레벨 시작 전까지)
    let levelMaxExp: Int

    /// 다음 레벨까지 필요한 총 경험치
    let expToNextLevel: Int

    /// 현재 레벨에서의 진행률 (0.0 ~ 1.0)
    let progress: Double

    /// 다음 레벨까지 남은 경험치
    let remainingExp: Int

    /// 최대 레벨인지 여부
    let isMaxLevel: Bool

    // MARK: - Initialization

    /// 현재 경험치로 레벨 정보를 계산하여 초기화
    init(currentExp: Int) {
        self.currentExp = currentExp
        self.currentLevel = Level.calculateLevel(from: currentExp)
        self.levelMinExp = Level.getMinExpForLevel(self.currentLevel)
        self.levelMaxExp = Level.getMaxExpForLevel(self.currentLevel)
        self.expToNextLevel = self.levelMaxExp - self.levelMinExp
        self.isMaxLevel = self.currentLevel >= Level.maxLevel
        self.remainingExp = self.isMaxLevel ? 0 : self.levelMaxExp - self.currentExp

        // 진행률 계산 (현재 레벨 내에서의 진행률)
        if self.isMaxLevel {
            self.progress = 1.0
        } else {
            let currentLevelExp = self.currentExp - self.levelMinExp
            self.progress = Double(currentLevelExp) / Double(self.expToNextLevel)
        }
    }

    /// 레벨과 경험치로 직접 초기화
    init(level: Int, exp: Int) {
        self.currentLevel = min(level, Level.maxLevel)
        self.currentExp = exp
        self.levelMinExp = Level.getMinExpForLevel(self.currentLevel)
        self.levelMaxExp = Level.getMaxExpForLevel(self.currentLevel)
        self.expToNextLevel = self.levelMaxExp - self.levelMinExp
        self.remainingExp = max(0, self.levelMaxExp - self.currentExp)
        self.isMaxLevel = self.currentLevel >= Level.maxLevel

        // 진행률 계산
        if self.isMaxLevel {
            self.progress = 1.0
        } else {
            let currentLevelExp = max(0, self.currentExp - self.levelMinExp)
            self.progress = Double(currentLevelExp) / Double(self.expToNextLevel)
        }
    }

    // MARK: - Static Methods

    /// 최대 레벨
    static let maxLevel = 100

    /// 특정 경험치에 해당하는 레벨 계산
    static func calculateLevel(from exp: Int) -> Int {
        var level = 1

        while level < maxLevel {
            let levelMaxExp = getMaxExpForLevel(level)
            if exp < levelMaxExp {
                break
            }
            level += 1
        }

        return min(level, maxLevel)
    }

    /// 특정 레벨의 최소 경험치
    static func getMinExpForLevel(_ level: Int) -> Int {
        if level <= 1 { return 0 }

        var totalExp = 0
        for i in 1..<level {
            totalExp += getExpRequiredForLevel(i)
        }
        return totalExp
    }

    /// 특정 레벨의 최대 경험치
    static func getMaxExpForLevel(_ level: Int) -> Int {
        return getMinExpForLevel(level) + getExpRequiredForLevel(level)
    }

    /// 특정 레벨을 올리기 위해 필요한 경험치량
    static func getExpRequiredForLevel(_ level: Int) -> Int {
        switch level {
        case 1...10:
            // Lv.1-10: 10씩 증가 (10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
            return level * 10
        case 11...20:
            // Lv.11-20: 20씩 증가 (120, 140, 160, 180, 200, ...)
            return 100 + (level - 10) * 20
        case 21...30:
            // Lv.21-30: 30씩 증가 (390, 420, 450, 480, 510, ...)
            return 100 + 10 * 20 + (level - 20) * 30
        case 31...maxLevel:
            // Lv.31+: 50씩 증가
            return 100 + 10 * 20 + 10 * 30 + (level - 30) * 50
        default:
            return 10
        }
    }

    /// 경험치 추가 시 새로운 레벨 정보 계산
    static func addExperience(currentExp: Int, expToAdd: Int) -> (newLevel: Level, leveledUp: Bool, levelsGained: Int) {
        let newTotalExp = currentExp + expToAdd
        let oldLevel = calculateLevel(from: currentExp)
        let newLevel = calculateLevel(from: newTotalExp)

        let leveledUp = newLevel > oldLevel
        let levelsGained = newLevel - oldLevel

        return (Level(currentExp: newTotalExp), leveledUp, levelsGained)
    }

    // MARK: - Instance Methods

    /// 경험치 추가
    func addExperience(_ exp: Int) -> (newLevel: Level, leveledUp: Bool, levelsGained: Int) {
        return Level.addExperience(currentExp: self.currentExp, expToAdd: exp)
    }

    /// 특정 경험치만큼 감소 (최소 0)
    func subtractExperience(_ exp: Int) -> Level {
        let newExp = max(0, self.currentExp - exp)
        return Level(currentExp: newExp)
    }

    // MARK: - Computed Properties

    /// 레벨 업까지 필요한 경험치 퍼센트 (문자열)
    var progressPercentage: String {
        let percentage = Int(progress * 100)
        return "\(percentage)%"
    }

    /// 현재 레벨 정보 요약
    var levelInfo: String {
        if isMaxLevel {
            return "Lv.\(currentLevel) (MAX)"
        } else {
            return "Lv.\(currentLevel) (\(progressPercentage))"
        }
    }

    /// 디버그용 정보
    var debugInfo: String {
        """
        Level: \(currentLevel)
        EXP: \(currentExp)/\(levelMaxExp)
        Progress: \(progressPercentage)
        To Next: \(remainingExp) EXP
        Max Level: \(isMaxLevel)
        """
    }
}
