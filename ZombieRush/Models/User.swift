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
    var level: Int         // 레벨
    var exp: Int          // 경험치
    var nemoFruit: Int    // 네모 과일 (코인)
    var cheerBuff: Bool   // 응원 버프
    var createdAt: Date   // 생성일
    var updatedAt: Date   // 수정일

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case nickname
        case level
        case exp
        case nemoFruit = "nemo_fruit"
        case cheerBuff = "cheer_buff"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(playerId: String, nickname: String, level: Int = 1, exp: Int = 0, nemoFruit: Int = 0, cheerBuff: Bool = false) {
        self.playerId = playerId
        self.nickname = nickname
        self.level = level
        self.exp = exp
        self.nemoFruit = nemoFruit
        self.cheerBuff = cheerBuff
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
