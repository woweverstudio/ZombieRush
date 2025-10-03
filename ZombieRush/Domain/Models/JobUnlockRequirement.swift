//
//  JobUnlockRequirement.swift
//  ZombieRush
//
//  Created by Job Unlock Requirements from Supabase
//

import Foundation

/// 서버에서 로드하는 직업 해금 요구사항 모델
struct JobUnlockRequirement: Codable, Identifiable {
    let jobKey: String        // 직업 키 (primary key)
    let requiredLevel: Int    // 필요한 레벨
    let requiredSpirit: String // 필요한 원소 타입
    let requiredCount: Int    // 필요한 개수

    var id: String { jobKey }

    enum CodingKeys: String, CodingKey {
        case jobKey = "job_key"
        case requiredLevel = "required_level"
        case requiredSpirit = "required_spirit"
        case requiredCount = "required_count"
    }
}

// MARK: - Static Access (JobStats 패턴과 동일)
extension JobUnlockRequirement {
    private static var requirements: [String: JobUnlockRequirement] = [:]

    /// 서버에서 로드한 요구사항 저장
    static func loadRequirements(_ requirements: [JobUnlockRequirement]) {
        self.requirements = Dictionary(uniqueKeysWithValues: requirements.map { ($0.jobKey, $0) })
    }

    /// 특정 직업의 요구사항 조회
    static func requirement(for jobKey: String) -> JobUnlockRequirement? {
        return requirements[jobKey]
    }

    /// 모든 요구사항 조회
    static func allRequirements() -> [JobUnlockRequirement] {
        return Array(requirements.values)
    }

    /// 요구사항 존재 여부
    static func hasRequirement(for jobKey: String) -> Bool {
        return requirements[jobKey] != nil
    }
}
