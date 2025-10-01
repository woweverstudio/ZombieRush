//
//  Spirits.swift
//  ZombieRush
//
//  Created by Spirits Domain Model for Supabase Integration
//

import Foundation

/// Supabase spirits 테이블의 원소 모델
struct Spirits: Codable, Identifiable {
    let playerId: String   // Game Center gamePlayerID (계정별 고유 식별자, foreign key to users)
    var fire: Int         // 불 속성 원소
    var ice: Int          // 얼음 속성 원소
    var lightning: Int    // 번개 속성 원소
    var dark: Int         // 어둠 속성 원소

    var id: String { playerId } // Identifiable 프로토콜 준수

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case fire
        case ice
        case lightning
        case dark
    }

    init(playerId: String, fire: Int = 0, ice: Int = 0, lightning: Int = 0, dark: Int = 0) {
        self.playerId = playerId
        self.fire = fire
        self.ice = ice
        self.lightning = lightning
        self.dark = dark
    }

    /// 기본 원소 생성
    static func defaultSpirits(for playerId: String) -> Spirits {
        return Spirits(playerId: playerId)
    }

    /// 총 원소 개수 계산
    var totalCount: Int {
        return fire + ice + lightning + dark
    }
}
