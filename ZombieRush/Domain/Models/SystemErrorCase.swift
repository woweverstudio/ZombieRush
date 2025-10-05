//
//  SystemErrorCase.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

enum SystemErrorCase {
    case userNotFound
    case dataNotFound
    case databaseRequestFailed

    // IAP 관련 에러 케이스
    case iapProductsLoadFailed
    case iapPurchaseFailed

    var error: SystemError {
        switch self {
        case .userNotFound:
            return SystemError(source: .database, severity: .fatal, message: .cannotFoundUser)
        case .dataNotFound:
            return SystemError(source: .database, severity: .fatal, message: .cannotFoundData)
        case .databaseRequestFailed:
            return SystemError(source: .database, severity: .retry, message: .databaseReadFailed)

        // IAP 관련 에러
        case .iapProductsLoadFailed:
            return SystemError(source: .iap, severity: .retry, message: .iapLoadFailed)
        case .iapPurchaseFailed:
            return SystemError(source: .iap, severity: .retry, message: .iapPurchaseFailed)
        }
    }
}
