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
    case hpRecovery = "hp_recovery"
    case moveSpeed = "move_speed"
    case energyRecovery = "energy_recovery"
    case attackSpeed = "attack_speed"
    case totemCount = "totem_count"


    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .hpRecovery:
            return "heart.fill"
        case .moveSpeed:
            return "figure.walk"
        case .energyRecovery:
            return "bolt.fill"
        case .attackSpeed:
            return "flame.fill"
        case .totemCount:
            return "star.fill"
        }
    }

    /// 색상 (SwiftUI Color)
    var color: Color {
        switch self {
        case .hpRecovery:
            return .red
        case .moveSpeed:
            return .blue
        case .energyRecovery:
            return .yellow
        case .attackSpeed:
            return .orange
        case .totemCount:
            return .purple
        }
    }


    // MARK: - Localized Properties
    var localizedDisplayName: String {
        switch self {
        case .hpRecovery:
            return NSLocalizedString("stat_hp_recovery_name", tableName: "Models", comment: "HP recovery stat display name")
        case .moveSpeed:
            return NSLocalizedString("stat_move_speed_name", tableName: "Models", comment: "Move speed stat display name")
        case .energyRecovery:
            return NSLocalizedString("stat_energy_recovery_name", tableName: "Models", comment: "Energy recovery stat display name")
        case .attackSpeed:
            return NSLocalizedString("stat_attack_speed_name", tableName: "Models", comment: "Attack speed stat display name")
        case .totemCount:
            return NSLocalizedString("stat_totem_count_name", tableName: "Models", comment: "Totem count stat display name")
        }
    }

    var localizedDescription: String {
        switch self {
        case .hpRecovery:
            return NSLocalizedString("stat_hp_recovery_description", tableName: "Models", comment: "HP recovery stat description")
        case .moveSpeed:
            return NSLocalizedString("stat_move_speed_description", tableName: "Models", comment: "Move speed stat description")
        case .energyRecovery:
            return NSLocalizedString("stat_energy_recovery_description", tableName: "Models", comment: "Energy recovery stat description")
        case .attackSpeed:
            return NSLocalizedString("stat_attack_speed_description", tableName: "Models", comment: "Attack speed stat description")
        case .totemCount:
            return NSLocalizedString("stat_totem_count_description", tableName: "Models", comment: "Totem count stat description")
        }
    }
}
