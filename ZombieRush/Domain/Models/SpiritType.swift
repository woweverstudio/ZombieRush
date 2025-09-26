//
//  SpiritType.swift
//  ZombieRush
//
//  Created by Spirit Type Definition
//

import SwiftUI

/// 정령 타입 열거형
enum SpiritType: String, CaseIterable {
    case fire
    case ice
    case lightning
    case dark
}

// MARK: - SpiritType Extensions
extension SpiritType {
    var displayName: String {
        switch self {
        case .fire: return "불"
        case .ice: return "얼음"
        case .lightning: return "번개"
        case .dark: return "어둠"
        }
    }

    var iconName: String {
        switch self {
        case .fire: return "flame.fill"
        case .ice: return "snowflake"
        case .lightning: return "bolt.fill"
        case .dark: return "moon.fill"
        }
    }

    var color: Color {
        switch self {
        case .fire: return .red
        case .ice: return .blue
        case .lightning: return .yellow
        case .dark: return .purple
        }
    }

    var description: String {
        switch self {
        case .fire: return "화염 속성 공격에 특화된 정령"
        case .ice: return "빙결 효과를 가진 냉기 정령"
        case .lightning: return "빠른 전격 공격을 하는 번개 정령"
        case .dark: return "어둠의 힘을 사용하는 신비한 정령"
        }
    }
}
