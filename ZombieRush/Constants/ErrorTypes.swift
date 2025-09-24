//
////  ErrorTypes.swift
////  ZombieRush
////
////  Created by Error Types for Centralized Error Handling
////

import Foundation
import SwiftUI

/// 앱 전체 에러 타입
enum AppError: Error, Equatable {
    // 네트워크 에러 (중앙 집중식 에러 뷰 표시)
    case network(NetworkError)

    // 비즈니스 로직 에러 (토스트 메시지 - 나중에 구현)
    case business(BusinessError)
    case validation(ValidationError)

    // 예상치 못한 에러
    case unexpected(String)

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.network(let l), .network(let r)): return l == r
        case (.business(let l), .business(let r)): return l == r
        case (.validation(let l), .validation(let r)): return l == r
        case (.unexpected(let l), .unexpected(let r)): return l == r
        default: return false
        }
    }
}

/// 네트워크 관련 에러
enum NetworkError: Equatable {
    case timeout
    case noConnection
    case serverError(code: Int)
    case invalidResponse
}

/// 데이터베이스 관련 에러
enum DatabaseError: Equatable {
    case connectionFailed
    case queryFailed
    case dataNotFound
}

/// 비즈니스 로직 에러
enum BusinessError: Equatable {
    case insufficientPoints(needed: Int, current: Int)
    case insufficientSpirits(type: SpiritType, needed: Int, current: Int)
    case jobAlreadyUnlocked
    case maxLevelReached
    case invalidOperation(String)
}

/// 검증 관련 에러
enum ValidationError: Equatable {
    case invalidInput(field: String, reason: String)
    case missingData(entity: String)
    case outOfRange(value: String, min: Int, max: Int)
}

// MARK: - AppError UI 프로퍼티들 (네트워크 에러만 표시)
extension AppError {
    /// 네트워크 에러인 경우에만 표시할 에러 제목
    var title: String? {
        switch self {
        case .network: return "네트워크 오류"
        default: return nil // 비즈니스 에러는 표시하지 않음
        }
    }

    /// 네트워크 에러인 경우에만 표시할 메시지
    var userFriendlyMessage: String? {
        switch self {
        case .network(.timeout):
            return "네트워크 연결이 지연되고 있습니다.\n잠시 후 다시 시도해주세요."
        case .network(.noConnection):
            return "네트워크 연결을 확인해주세요."
        case .network(.serverError(let code)):
            return "서버 오류가 발생했습니다.\n(코드: \(code))"
        case .network(.invalidResponse):
            return "서버 응답이 올바르지 않습니다."
        default: return nil // 비즈니스 에러는 표시하지 않음
        }
    }

    /// 네트워크 에러인 경우에만 표시할 아이콘
    var icon: Image? {
        switch self {
        case .network:
            return Image(systemName: "wifi.exclamationmark")
        default: return nil // 비즈니스 에러는 표시하지 않음
        }
    }

    /// 네트워크 에러인 경우에만 표시할 색상
    var color: Color? {
        switch self {
        case .network: return .orange
        default: return nil // 비즈니스 에러는 표시하지 않음
        }
    }

    /// 네트워크 에러인지 확인
    var isNetworkError: Bool {
        switch self {
        case .network: return true
        default: return false
        }
    }
}
