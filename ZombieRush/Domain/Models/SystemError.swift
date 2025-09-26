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
    case cannotFoundUser = "Cannot found user"
    case databaseReadFailed = "Database update failed"    
}

struct SystemError: Identifiable {
    let id = UUID()
    let source: SystemErrorSource
    let severity: SystemErrorSeverity
    let message: SystemErrorDescription
}
