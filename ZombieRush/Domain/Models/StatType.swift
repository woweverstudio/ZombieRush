//
//  StatType.swift
//  ZombieRush
//
//  Created by Stat Type Enumeration
//

import Foundation
import SwiftUI  // Color를 위해 추가

/// 스탯 타입 열거형
/// Stats 모델의 각 스탯 필드에 대응
enum StatType: String, CaseIterable, Codable {
    case hp = "hp"
    case energy = "energy"
    case moveSpeed = "move_speed"
    case attackSpeed = "attack_speed"


    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .hp:
            return "heart.fill"
        case .energy:
            return "flame.fill"
        case .moveSpeed:
            return "shoeprints.fill"
        case .attackSpeed:
            return "bolt.fill"
        }
    }

    /// 색상 (SwiftUI Color)
    var color: Color {
        switch self {
        case .hp:
            return .red
        case .energy:
            return .blue
        case .moveSpeed:
            return .green
        case .attackSpeed:
            return .yellow
        }
    }


    // MARK: - Localized Properties
    var localizedDisplayName: String {
        switch self {
        case .hp:
            return NSLocalizedString("stat_hp_name", tableName: "Models", comment: "HP stat display name")
        case .moveSpeed:
            return NSLocalizedString("stat_move_speed_name", tableName: "Models", comment: "Move speed stat display name")
        case .energy:
            return NSLocalizedString("stat_energy_name", tableName: "Models", comment: "Energy stat display name")
        case .attackSpeed:
            return NSLocalizedString("stat_attack_speed_name", tableName: "Models", comment: "Attack speed stat display name")
        }
    }

    var localizedDescription: String {
        switch self {
        case .hp:
            return NSLocalizedString("stat_hp_description", tableName: "Models", comment: "HP stat description")
        case .moveSpeed:
            return NSLocalizedString("stat_move_speed_description", tableName: "Models", comment: "Move speed stat description")
        case .energy:
            return NSLocalizedString("stat_energy_description", tableName: "Models", comment: "Energy stat description")
        case .attackSpeed:
            return NSLocalizedString("stat_attack_speed_description", tableName: "Models", comment: "Attack speed stat description")
        }
    }
}

// MARK: - Stats Integration Extension
extension StatType {
    /// 주어진 Stats에서 이 StatType의 현재 값을 반환
    func value(in stats: Stats) -> Int {
        return stats[self]
    }

    /// 주어진 Stats에서 이 StatType의 값을 설정
    func setValue(_ value: Int, in stats: inout Stats) {
        stats[self] = value
    }
}
