//
//  JobType.swift
//  ZombieRush
//
//  Created by 김민성 on 10/2/25.
//
import Foundation

/// 직업 타입 열거형
enum JobType: String, CaseIterable, Hashable, Identifiable {
    case novice = "novice"
    case fireMage = "fire"
    case iceMage = "ice"
    case thunderMage = "thunder"
    case darkMage = "dark"
}

// MARK: - Localized Extensions
extension JobType {
    
    var id: String {
        return self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .novice: return "novice"
        case .fireMage: return "fire_mage"
        case .iceMage: return "ice_mage"
        case .thunderMage: return "thunder_mage"
        case .darkMage: return "dark_mage"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .novice:
            return NSLocalizedString("models_job_novice_name", tableName: "Common", comment: "Novice job name")
        case .fireMage:
            return NSLocalizedString("models_job_fire_mage_name", tableName: "Common", comment: "Fire mage job name")
        case .iceMage:
            return NSLocalizedString("models_job_ice_mage_name", tableName: "Common", comment: "Ice mage job name")
        case .thunderMage:
            return NSLocalizedString("models_job_thunder_mage_name", tableName: "Common", comment: "Thunder mage job name")
        case .darkMage:
            return NSLocalizedString("models_job_dark_mage_name", tableName: "Common", comment: "Dark mage job name")
        }
    }

    var localizedDescription: String {
        switch self {
        case .novice:
            return NSLocalizedString("models_job_novice_description", tableName: "Common", comment: "Novice job description")
        case .fireMage:
            return NSLocalizedString("models_job_fire_mage_description", tableName: "Common", comment: "Fire mage job description")
        case .iceMage:
            return NSLocalizedString("models_job_ice_mage_description", tableName: "Common", comment: "Ice mage job description")
        case .thunderMage:
            return NSLocalizedString("models_job_thunder_mage_description", tableName: "Common", comment: "Thunder mage job description")
        case .darkMage:
            return NSLocalizedString("models_job_dark_mage_description", tableName: "Common", comment: "Dark mage job description")
        }
    }
}

