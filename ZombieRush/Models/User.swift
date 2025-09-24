//
//  User.swift
//  ZombieRush
//
//  Created by User Domain Model for Supabase Integration
//

import Foundation

/// Supabase users 테이블의 사용자 모델
struct User: Codable, Identifiable {
    let playerId: String   // Game Center playerID (primary key)
    var nickname: String   // Game Center displayName
    var exp: Int          // 경험치 (레벨은 경험치로부터 계산)
    var nemoFruit: Int    // 네모 과일 (코인)
    var remainingPoints: Int  // 레벨업 시 증가하는 포인트
    var cheerBuffExpiresAt: Date?   // 네모의 응원 만료 시간
    var createdAt: Date   // 생성일
    var updatedAt: Date   // 수정일

    var id: String { playerId } // Identifiable 프로토콜 준수

    /// 계산된 레벨 (경험치로부터 자동 계산)
    var level: Int {
        return Level.calculateLevel(from: exp)
    }

    /// 레벨 객체 (상세 정보 포함)
    var levelInfo: Level {
        return Level(currentExp: exp)
    }

    /// 네모의 응원 활성화 상태
    var isCheerBuffActive: Bool {
        guard let expiresAt = cheerBuffExpiresAt else { return false }
        return expiresAt > Date()
    }

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case nickname
        case exp
        case nemoFruit = "nemo_fruit"
        case remainingPoints = "remaining_points"
        case cheerBuffExpiresAt = "cheer_buff_expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(playerId: String, nickname: String, exp: Int = 0, nemoFruit: Int = 0, remainingPoints: Int = 0, cheerBuffExpiresAt: Date? = nil) {
        self.playerId = playerId
        self.nickname = nickname
        self.exp = exp
        self.nemoFruit = nemoFruit
        self.remainingPoints = remainingPoints
        self.cheerBuffExpiresAt = cheerBuffExpiresAt
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
