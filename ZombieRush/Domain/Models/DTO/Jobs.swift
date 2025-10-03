//
//  Jobs.swift
//  ZombieRush
//
//  Created by Jobs Domain Model for Supabase Integration
//

import Foundation

/// Supabase jobs 테이블의 직업 모델
struct Jobs: Codable, Identifiable {
    let playerId: String   // Game Center gamePlayerID (계정별 고유 식별자, foreign key to users)
    var novice: Bool      // 초보자
    var fireMage: Bool    // 불 마법사
    var iceMage: Bool     // 얼음 마법사
    var thunderMage: Bool // 번개 마법사
    var darkMage: Bool    // 어둠 마법사
    var selectedJob: String // 선택된 직업

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case novice
        case fireMage = "fire"
        case iceMage = "ice"
        case thunderMage = "thunder"
        case darkMage = "dark"
        case selectedJob = "selected"
    }

    init(playerId: String, novice: Bool = true, fireMage: Bool = false, iceMage: Bool = false, thunderMage: Bool = false, darkMage: Bool = false, selectedJob: String = "novice") {
        self.playerId = playerId
        self.novice = novice
        self.fireMage = fireMage
        self.iceMage = iceMage
        self.thunderMage = thunderMage
        self.darkMage = darkMage
        self.selectedJob = selectedJob
    }

    /// 잠금 해제된 직업 목록
    var unlockedJobs: [JobType] {
        var jobs: [JobType] = []
        if novice { jobs.append(.novice) }
        if fireMage { jobs.append(.fireMage) }
        if iceMage { jobs.append(.iceMage) }
        if thunderMage { jobs.append(.thunderMage) }
        if darkMage { jobs.append(.darkMage) }
        return jobs
    }

    /// 선택된 직업 타입
    var selectedJobType: JobType {
        switch selectedJob {
        case "novice": return .novice
        case "fire": return .fireMage
        case "ice": return .iceMage
        case "thunder": return .thunderMage
        case "dark": return .darkMage
        default: return .novice
        }
    }

    /// 특정 StatType의 기본값을 반환
    func baseValue(jobType: JobType, statType: StatType) -> Int {
        let jobStats = JobStats.getStats(for: jobType.rawValue)
        
        switch statType {
        case .hp:
            return jobStats.hp
        case .moveSpeed:
            return jobStats.moveSpeed
        case .energy:
            return jobStats.energy
        case .attackSpeed:
            return jobStats.attackSpeed
        }
    }
}
