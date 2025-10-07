//
//  ToastMessage.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

enum ToastMessage: Identifiable {
    case unlockJob(String)
    case addElement(String, Color, String, Int)
    case addGem(Int)
    case iapPending

    var id: String {
        switch self {
        case .unlockJob:
            return "unlockJob"
        case .addElement:
            return "addElement"
        case .addGem:
            return "addGem"
        case .iapPending:
            return "iapPending"
        }
    }

    var icon: String {
        switch self {
        case .unlockJob:
            return "sparkles"
        case .addElement(let iconName, _, _, _):
            return iconName
        case .addGem:
            return "diamond.fill"
        case .iapPending:
            return "hourglass"
        }
    }

    var color: Color {
        switch self {
        case .unlockJob:
            return .yellow
        case .addElement(_, let color, _, _):
            return color
        case .addGem:
            return Color(hex: "8CFFE4")
        case .iapPending:
            return .dsError
        }
    }

    var message: String {
        switch self {
        case .unlockJob(let jobName):
            return String(format: NSLocalizedString("toast_unlock_job", tableName: "Alert", comment: "Toast message for unlocking a job"), jobName)
        case .addElement(_, _, let elementName, let count):
            return String(format: NSLocalizedString("toast_add_element", tableName: "Alert", comment: "Toast message for adding elements"), elementName, count)
        case .addGem(let count):
            return String(format: NSLocalizedString("toast_add_gem", tableName: "Alert", comment: "Toast message for adding gems"), count)
        case .iapPending:
            return NSLocalizedString("toast_iap_pending", tableName: "Alert", comment: "Toast message for IAP pending status")
        }
    }
}
