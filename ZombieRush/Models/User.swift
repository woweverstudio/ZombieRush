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
    var cheerBuff: Bool   // 응원 버프
    var createdAt: Date   // 생성일
    var updatedAt: Date   // 수정일

    var id: String { playerId } // Identifiable 프로토콜 준수

    /// 계산된 레벨 (경험치로부터 자동 계산)
    var level: Int {
        return Level.calculateLevel(from: exp)
    }

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case nickname
        case exp
        case nemoFruit = "nemo_fruit"
        case remainingPoints = "remaining_points"
        case cheerBuff = "cheer_buff"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(playerId: String, nickname: String, exp: Int = 0, nemoFruit: Int = 0, remainingPoints: Int = 0, cheerBuff: Bool = false) {
        self.playerId = playerId
        self.nickname = nickname
        self.exp = exp
        self.nemoFruit = nemoFruit
        self.remainingPoints = remainingPoints
        self.cheerBuff = cheerBuff
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
