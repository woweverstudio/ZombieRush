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

    /// 표시 이름
    var displayName: String {
        switch self {
        case .hpRecovery:
            return "HP 회복"
        case .moveSpeed:
            return "이동 속도"
        case .energyRecovery:
            return "에너지 회복"
        case .attackSpeed:
            return "공격 속도"
        case .totemCount:
            return "토템 개수"
        }
    }

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
}
