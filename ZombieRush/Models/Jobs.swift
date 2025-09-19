//
//  Jobs.swift
//  ZombieRush
//
//  Created by Jobs Domain Model for Supabase Integration
//

import Foundation

/// Supabase jobs 테이블의 직업 모델
struct Jobs: Codable, Identifiable {
    let playerId: String   // Game Center playerID (foreign key to users)
    var novice: Bool      // 초보자
    var fireMage: Bool    // 불 마법사
    var iceMage: Bool     // 얼음 마법사
    var lightningMage: Bool // 번개 마법사
    var darkMage: Bool    // 어둠 마법사
    var selectedJob: String // 선택된 직업

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case novice
        case fireMage = "fire_mage"
        case iceMage = "ice_mage"
        case lightningMage = "lightning_mage"
        case darkMage = "dark_mage"
        case selectedJob = "selected_job"
    }

    init(playerId: String, novice: Bool = true, fireMage: Bool = false, iceMage: Bool = false, lightningMage: Bool = false, darkMage: Bool = false, selectedJob: String = "novice") {
        self.playerId = playerId
        self.novice = novice
        self.fireMage = fireMage
        self.iceMage = iceMage
        self.lightningMage = lightningMage
        self.darkMage = darkMage
        self.selectedJob = selectedJob
    }

    /// 기본 직업 생성
    static func defaultJobs(for playerId: String) -> Jobs {
        return Jobs(playerId: playerId)
    }

    /// 잠금 해제된 직업 목록
    var unlockedJobs: [JobType] {
        var jobs: [JobType] = []
        if novice { jobs.append(.novice) }
        if fireMage { jobs.append(.fireMage) }
        if iceMage { jobs.append(.iceMage) }
        if lightningMage { jobs.append(.lightningMage) }
        if darkMage { jobs.append(.darkMage) }
        return jobs
    }

    /// 선택된 직업 타입
    var selectedJobType: JobType {
        switch selectedJob {
        case "novice": return .novice
        case "fire_mage": return .fireMage
        case "ice_mage": return .iceMage
        case "lightning_mage": return .lightningMage
        case "dark_mage": return .darkMage
        default: return .novice
        }
    }
}

/// 직업 타입 열거형
enum JobType: String, CaseIterable {
    case novice = "novice"
    case fireMage = "fire_mage"
    case iceMage = "ice_mage"
    case lightningMage = "lightning_mage"
    case darkMage = "dark_mage"

    var displayName: String {
        switch self {
        case .novice: return "초보자"
        case .fireMage: return "불 마법사"
        case .iceMage: return "얼음 마법사"
        case .lightningMage: return "번개 마법사"
        case .darkMage: return "어둠 마법사"
        }
    }

    var iconName: String {
        switch self {
        case .novice: return "person.fill"
        case .fireMage: return "flame.fill"
        case .iceMage: return "snowflake"
        case .lightningMage: return "bolt.fill"
        case .darkMage: return "moon.fill"
        }
    }
}
