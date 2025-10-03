//
//  Stats.swift
//  ZombieRush
//
//  Created by Stats Domain Model for Supabase Integration
//

import Foundation

/// Supabase stats 테이블의 사용자 통계 모델
struct Stats: Codable, Identifiable {
    let playerId: String   // Game Center gamePlayerID (계정별 고유 식별자, foreign key to users)
    var hp: Int            // 체력
    var moveSpeed: Int     // 이동 속도
    var energy: Int        // 에너지
    var attackSpeed: Int   // 공격 속도

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case hp = "hp"
        case moveSpeed = "move_speed"
        case energy = "energy"
        case attackSpeed = "attack_speed"
    }

    init(playerId: String, hp: Int = 0, moveSpeed: Int = 0, energy: Int = 0, attackSpeed: Int = 0) {
        self.playerId = playerId
        self.hp = hp
        self.moveSpeed = moveSpeed
        self.energy = energy
        self.attackSpeed = attackSpeed
    }

    /// 기본 스탯 생성
    static func defaultStats(for playerId: String) -> Stats {
        return Stats(playerId: playerId)
    }
}

// MARK: - StatType Subscript Extension
extension Stats {
    /// StatType으로 스탯 값에 접근하기 위한 subscript
    subscript(statType: StatType) -> Int {
        get {
            switch statType {
            case .hp: return hp
            case .moveSpeed: return moveSpeed
            case .energy: return energy
            case .attackSpeed: return attackSpeed
            }
        }
        set {
            switch statType {
            case .hp: hp = newValue
            case .moveSpeed: moveSpeed = newValue
            case .energy: energy = newValue
            case .attackSpeed: attackSpeed = newValue
            }
        }
    }
}
