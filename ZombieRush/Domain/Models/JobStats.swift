//
//  JobStats.swift
//  ZombieRush
//
//  Created by Job Stats Domain Model for Game Balance
//

import Foundation

/// 직업 해금 요구사항
struct JobUnlockRequirement {
    let spiritType: String // SpiritType의 rawValue
    let count: Int        // 필요한 개수
    let requiredLevel: Int // 필요한 레벨
}

/// 직업별 스탯 데이터 모델 (정적 데이터)
struct JobStats {
    let jobKey: String    // 직업 키
    let hp: Int          // 체력
    let energy: Int      // 에너지
    let moveSpeed: Int        // 이동 속도
    let attackSpeed: Int // 공격 속도
    let unlockRequirement: JobUnlockRequirement? // 해금 조건

    private static let defaults = JobStats(jobKey: "novice", hp: 100, energy: 100, moveSpeed: 10, attackSpeed: 10, unlockRequirement: nil)
    
    // 정적 데이터 딕셔너리
    private static let statsData: [String: JobStats] = [
        "novice": JobStats(jobKey: "novice", hp: 100, energy: 100, moveSpeed: 10, attackSpeed: 10, unlockRequirement: nil),
        "fire_mage": JobStats(jobKey: "fire_mage", hp: 120, energy: 110, moveSpeed: 10, attackSpeed: 10, unlockRequirement: JobUnlockRequirement(spiritType: "fire", count: 15, requiredLevel: 10)),
        "ice_mage": JobStats(jobKey: "ice_mage", hp: 90, energy: 80, moveSpeed: 10, attackSpeed: 10, unlockRequirement: JobUnlockRequirement(spiritType: "ice", count: 15, requiredLevel: 10)),
        "lightning_mage": JobStats(jobKey: "lightning_mage", hp: 100, energy: 110, moveSpeed: 14, attackSpeed: 10, unlockRequirement: JobUnlockRequirement(spiritType: "lightning", count: 20, requiredLevel: 10)),
        "dark_mage": JobStats(jobKey: "dark_mage", hp: 85, energy: 115, moveSpeed: 10, attackSpeed: 14, unlockRequirement: JobUnlockRequirement(spiritType: "dark", count: 25, requiredLevel: 20))
    ]

    /// 모든 스탯 데이터 (배열 형태로 반환)
    static var allStats: [JobStats] {
        return Array(statsData.values)
    }
    
    static func getStats(for jobKey: String) -> JobStats {
        return statsData[jobKey, default: .defaults]
    }
    
    /// 특정 jobKey의 스탯을 가져옴
    static func getStat(job: JobType, stat: StatType) -> Int {
        return statsData[job.rawValue, default: .defaults][stat]
    }
}

// MARK: - StatType Subscript Extension
extension JobStats {
    /// StatType으로 스탯 값에 접근하기 위한 subscript
    subscript(statType: StatType) -> Int {
        get {
            switch statType {
            case .hp: return hp
            case .energy: return energy
            case .moveSpeed: return moveSpeed
            case .attackSpeed: return attackSpeed
            }
        }
    }
}
