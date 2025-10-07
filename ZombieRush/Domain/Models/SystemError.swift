//
//  SystemError.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

enum SystemError: Identifiable {
    case serverError

    var id: String {
        switch self {
        case .serverError:
            return "serverError"
        }
    }

    var title: String {
        switch self {
        case .serverError:
            return NSLocalizedString("error_server_title", tableName: "Alert", comment: "Server error title")
        }
    }

    var icon: String {
        switch self {
        case .serverError:
            return "exclamationmark.triangle.fill"
        }
    }

    var message: String {
        switch self {
        case .serverError:
            return NSLocalizedString("error_server_failed", tableName: "Alert", comment: "Server error message")
        }
    }
}
