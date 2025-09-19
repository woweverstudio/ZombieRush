//
//  JobStats.swift
//  ZombieRush
//
//  Created by Job Stats Domain Model for Game Balance
//

import Foundation

/// 직업별 스탯 데이터 모델 (정적 데이터)
struct JobStats {
    let jobKey: String    // 직업 키
    let hp: Int          // 체력
    let energy: Int      // 에너지
    let move: Int        // 이동 속도
    let attackSpeed: Int // 공격 속도

    // 정적 데이터 딕셔너리
    private static let statsData: [String: JobStats] = [
        "novice": JobStats(jobKey: "novice", hp: 100, energy: 100, move: 10, attackSpeed: 10),
        "fire_mage": JobStats(jobKey: "fire_mage", hp: 120, energy: 110, move: 10, attackSpeed: 10),
        "ice_mage": JobStats(jobKey: "ice_mage", hp: 90, energy: 80, move: 10, attackSpeed: 10),
        "lightning_mage": JobStats(jobKey: "lightning_mage", hp: 100, energy: 110, move: 14, attackSpeed: 10),
        "dark_mage": JobStats(jobKey: "dark_mage", hp: 85, energy: 115, move: 10, attackSpeed: 14)
    ]

    /// 모든 스탯 데이터 (배열 형태로 반환)
    static var allStats: [JobStats] {
        return Array(statsData.values)
    }

    /// 특정 jobKey의 스탯을 가져옴
    static func getStats(for jobKey: String) -> JobStats? {
        return statsData[jobKey]
    }
}
