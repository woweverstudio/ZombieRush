//
//  StoreError.swift
//  ZombieRush
//
//  Created by Store Error Types
//

import Foundation

/// 스토어 관련 에러 타입들
enum StoreError: LocalizedError {
    case productLoadFailed
    case productNotFound
    case purchaseFailed
    case purchaseCancelled
    case purchasePending
    case transactionVerificationFailed
    case unknownProductType

    var errorDescription: String {
        switch self {
        case .productLoadFailed:
            return StoreConstants.ErrorMessages.productLoadFailed
        case .productNotFound:
            return StoreConstants.ErrorMessages.productNotFound
        case .purchaseFailed:
            return StoreConstants.ErrorMessages.purchaseFailed
        case .purchaseCancelled:
            return StoreConstants.ErrorMessages.purchaseCancelled
        case .purchasePending:
            return StoreConstants.ErrorMessages.purchasePending
        case .transactionVerificationFailed:
            return "트랜잭션 검증에 실패했습니다"
        case .unknownProductType:
            return "알 수 없는 상품 타입입니다"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .productLoadFailed:
            return "네트워크 연결을 확인하고 다시 시도해주세요"
        case .productNotFound:
            return "요청하신 상품을 찾을 수 없습니다"
        case .purchaseFailed:
            return "결제 시스템에 문제가 발생했습니다. 다시 시도해주세요"
        case .purchaseCancelled:
            return "구매가 취소되었습니다"
        case .purchasePending:
            return "구매가 진행 중입니다. 잠시 기다려주세요"
        case .transactionVerificationFailed:
            return "거래 검증에 실패했습니다. 고객 지원팀에 문의해주세요"
        case .unknownProductType:
            return "지원하지 않는 상품 타입입니다"
        }
    }
}
