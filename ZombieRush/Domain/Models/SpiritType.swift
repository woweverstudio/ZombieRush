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

    // MARK: - Localized Properties
    var localizedDisplayName: String {
        switch self {
        case .fire:
            return NSLocalizedString("spirit_fire_name", tableName: "Models", comment: "Fire spirit display name")
        case .ice:
            return NSLocalizedString("spirit_ice_name", tableName: "Models", comment: "Ice spirit display name")
        case .lightning:
            return NSLocalizedString("spirit_lightning_name", tableName: "Models", comment: "Lightning spirit display name")
        case .dark:
            return NSLocalizedString("spirit_dark_name", tableName: "Models", comment: "Dark spirit display name")
        }
    }

    var localizedDescription: String {
        switch self {
        case .fire:
            return NSLocalizedString("spirit_fire_description", tableName: "Models", comment: "Fire spirit description")
        case .ice:
            return NSLocalizedString("spirit_ice_description", tableName: "Models", comment: "Ice spirit description")
        case .lightning:
            return NSLocalizedString("spirit_lightning_description", tableName: "Models", comment: "Lightning spirit description")
        case .dark:
            return NSLocalizedString("spirit_dark_description", tableName: "Models", comment: "Dark spirit description")
        }
    }
}
