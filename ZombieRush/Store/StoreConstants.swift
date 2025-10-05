//
//  StoreConstants.swift
//  ZombieRush
//
//  Created by Store Constants
//

import Foundation

/// 스토어 관련 상수들
enum StoreConstants {
    /// 상품 ID들
    enum ProductIDs {
        static let gem20 = "woweverstudio_gem_20"
        static let gem55 = "woweverstudio_gem_55"
        static let gem120 = "woweverstudio_gem_120"

        /// 모든 상품 ID 배열
        static let all: [String] = [gem20, gem55, gem120]
    }

    /// 에러 메시지
    enum ErrorMessages {
        static let productLoadFailed = "상품 로드에 실패했습니다"
        static let productNotFound = "상품을 찾을 수 없습니다"
        static let purchaseFailed = "구매에 실패했습니다"
        static let purchaseCancelled = "구매가 취소되었습니다"
        static let purchasePending = "구매가 진행 중입니다"
    }

    /// 로딩 메시지
    enum LoadingMessages {
        static let loadingProducts = "상품을 불러오는 중..."
        static let purchasing = "구매 진행 중..."
    }
}
