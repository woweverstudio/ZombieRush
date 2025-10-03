//
//  JobType.swift
//  ZombieRush
//
//  Created by 김민성 on 10/2/25.
//
import Foundation

/// 직업 타입 열거형
enum JobType: String, CaseIterable, Hashable {
    case novice = "novice"
    case fireMage = "fire"
    case iceMage = "ice"
    case thunderMage = "thunder"
    case darkMage = "dark"


    var imageName: String {
        switch self {
        case .novice: return "novice"
        case .fireMage: return "fire_mage"
        case .iceMage: return "ice_mage"
        case .thunderMage: return "thunder_mage"
        case .darkMage: return "dark_mage"
        }
    }
}

// MARK: - Localized Extensions
extension JobType {
    var localizedDisplayName: String {
        switch self {
        case .novice:
            return NSLocalizedString("job_novice_name", tableName: "Models", comment: "Novice job display name")
        case .fireMage:
            return NSLocalizedString("job_fire_mage_name", tableName: "Models", comment: "Fire mage job display name")
        case .iceMage:
            return NSLocalizedString("job_ice_mage_name", tableName: "Models", comment: "Ice mage job display name")
        case .thunderMage:
            return NSLocalizedString("job_thunder_mage_name", tableName: "Models", comment: "Thunder mage job display name")
        case .darkMage:
            return NSLocalizedString("job_dark_mage_name", tableName: "Models", comment: "Dark mage job display name")
        }
    }
}

