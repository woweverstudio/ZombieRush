//
//  GemItem.swift
//  ZombieRush
//
//  Created by Store Item Model
//

import Foundation
import StoreKit

/// 스토어 아이템 모델
struct GemItem: Identifiable {
    let id: String /// 고유 ID
    let name: String /// 아이템 이름
    let description: String /// 아이템 설명 현지화 파일에서 로드
    let price: String /// 가격 정보 (StoreKit의 displayPrice)
    let priceValue: Decimal /// 실제 가격 값 (StoreKit의 price)
    let currencyCode: String? /// 통화 코드
    let iconName: String /// 아이콘 이미지 이름
    let product: Product /// storekit product model

    // MARK: - Initialization

    /// StoreKit Product로부터 StoreItem 생성
    init(from product: Product) {
        self.id = product.id
        self.name = product.displayName
        self.description = Self.getLocalizedDescription(for: product.id)
        self.price = product.displayPrice
        self.priceValue = product.price
        self.currencyCode = product.priceFormatStyle.currencyCode
        self.iconName = Self.getIconName(for: product.id)
        self.product = product
    }

    /// Product ID에 따른 localized description 반환
    private static func getLocalizedDescription(for productId: String) -> String {
        switch productId {
        case ProductIDs.gem20:
            return NSLocalizedString("market_item_description_20", tableName: "View", comment: "")
        case ProductIDs.gem55:
            return NSLocalizedString("market_item_description_55", tableName: "View", comment: "")
        case ProductIDs.gem120:
            return NSLocalizedString("market_item_description_120", tableName: "View", comment: "")
        default:
            return NSLocalizedString("market_item_description_20", tableName: "View", comment: "")
        }
    }

    /// Product ID에 따른 아이콘 이름 반환
    private static func getIconName(for productId: String) -> String {
        switch productId {
        case ProductIDs.gem20:
            return "gem_20"
        case ProductIDs.gem55:
            return "gem_55"
        case ProductIDs.gem120:
            return "gem_120"
        default:
            return "gem_20"
        }
    }
}
