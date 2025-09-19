//
//  Stats.swift
//  ZombieRush
//
//  Created by Stats Domain Model for Supabase Integration
//

import Foundation

/// Supabase stats 테이블의 사용자 통계 모델
struct Stats: Codable, Identifiable {
    let playerId: String   // Game Center playerID (foreign key to users)
    var hpRecovery: Int    // HP 회복량
    var moveSpeed: Int     // 이동 속도
    var energyRecovery: Int // 에너지 회복량
    var attackSpeed: Int   // 공격 속도
    var totemCount: Int    // 토템 개수

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case hpRecovery = "hp_recovery"
        case moveSpeed = "move_speed"
        case energyRecovery = "energy_recovery"
        case attackSpeed = "attack_speed"
        case totemCount = "totem_count"
    }

    init(playerId: String, hpRecovery: Int = 0, moveSpeed: Int = 0, energyRecovery: Int = 0, attackSpeed: Int = 0, totemCount: Int = 0) {
        self.playerId = playerId
        self.hpRecovery = hpRecovery
        self.moveSpeed = moveSpeed
        self.energyRecovery = energyRecovery
        self.attackSpeed = attackSpeed
        self.totemCount = totemCount
    }

    /// 기본 스탯 생성
    static func defaultStats(for playerId: String) -> Stats {
        return Stats(playerId: playerId)
    }
}
