//
//  ElementType.swift
//  ZombieRush
//
//  Created by Element Type Definition
//

import SwiftUI

/// 원소 타입 열거형
enum ElementType: String, CaseIterable, Identifiable {
    case fire
    case ice
    case thunder
    case dark
}

// MARK: - ElementType Extensions
extension ElementType {
    var id: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .fire: return "flame.fill"
        case .ice: return "snowflake"
        case .thunder: return "bolt.fill"
        case .dark: return "moon.fill"
        }
    }

    var color: Color {
        switch self {
        case .fire: return .red
        case .ice: return .blue
        case .thunder: return .yellow
        case .dark: return .purple
        }
    }

    // MARK: - Localized Properties
    var localizedDisplayName: String {
        switch self {
        case .fire:
            return NSLocalizedString("models_element_fire_name", tableName: "Common", comment: "Fire element name")
        case .ice:
            return NSLocalizedString("models_element_ice_name", tableName: "Common", comment: "Ice element name")
        case .thunder:
            return NSLocalizedString("models_element_thunder_name", tableName: "Common", comment: "Thunder element name")
        case .dark:
            return NSLocalizedString("models_element_dark_name", tableName: "Common", comment: "Dark element name")
        }
    }

    var localizedDescription: String {
        switch self {
        case .fire:
            return NSLocalizedString("models_element_fire_description", tableName: "Common", comment: "Fire element description")
        case .ice:
            return NSLocalizedString("models_element_ice_description", tableName: "Common", comment: "Ice element description")
        case .thunder:
            return NSLocalizedString("models_element_thunder_description", tableName: "Common", comment: "Thunder element description")
        case .dark:
            return NSLocalizedString("models_element_dark_description", tableName: "Common", comment: "Dark element description")
        }
    }
}
