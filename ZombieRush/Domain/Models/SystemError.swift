//
//  SystemError.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

enum SystemErrorSeverity {
    case retry      // 재시도 가능
    case acknowledge // 확인 후 계속
    case fatal       // 앱 종료 필요
}

enum SystemErrorSource {
    case gamekit
    case database
    case iap
    case unknown
}

enum SystemErrorDescription: String {
    case cannotFoundUser
    case cannotFoundData
    case databaseReadFailed
    case iapPurchaseFailed
    case iapLoadFailed
}

// MARK: - Localized Extensions
extension SystemErrorDescription {
    var localizedMessage: String {
        switch self {
        case .cannotFoundUser:
            return NSLocalizedString("models_error_user_not_found", tableName: "Alert", comment: "User not found error message")
        case .cannotFoundData:
            return NSLocalizedString("models_error_data_not_found", tableName: "Alert", comment: "Data not found error message")
        case .databaseReadFailed:
            return NSLocalizedString("models_error_database_failed", tableName: "Alert", comment: "Database operation failed error message")
        case .iapLoadFailed:
            return "TODO: IAP 로드 실패"
        case .iapPurchaseFailed:
            return "TODO: IAP 구입 실패"
        }
    }
}

struct SystemError: Identifiable {
    let id = UUID()
    let source: SystemErrorSource
    let severity: SystemErrorSeverity
    let message: SystemErrorDescription
}
