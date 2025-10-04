//
//  MarketItems.swift
//  ZombieRush
//
//  Created by Market Item Models for In-App Purchases
//

import Foundation

// MARK: - Market Item Types (마켓 관련 타입들)

/// 마켓 아이템 타입
enum MarketItemType {
    case gemPackage(count: Int, price: Int)
}

/// 마켓 아이템
struct MarketItem: Identifiable {
    let id = UUID()
    let type: MarketItemType
    let name: String
    let englishName: String
    let descriptionKey: String
    let iconName: String
    let price: Int
    let currencyType: CurrencyType

    enum CurrencyType {
        case won
        case gem
    }
}

// MARK: - Market Items Manager

/// 마켓 아이템 관리자
struct MarketItemsManager {
    /// 마켓 아이템 목록 (기본 아이템들)
    static var marketItems: [MarketItem] {
        [
            // 젬 패키지
            MarketItem(
                type: .gemPackage(count: 20, price: 2000),
                name: "네모잼 20개",
                englishName: "20 Block Gems",
                descriptionKey: "market_item_description_20",
                iconName: "diamond.fill",
                price: 2000,
                currencyType: .won
            ),
            MarketItem(
                type: .gemPackage(count: 55, price: 5000),
                name: "네모잼 55개",
                englishName: "55 Block Gems",
                descriptionKey: "market_item_description_55",
                iconName: "diamond.fill",
                price: 5000,
                currencyType: .won
            ),
            MarketItem(
                type: .gemPackage(count: 120, price: 10000),
                name: "네모잼 120개",
                englishName: "120 Block Gems",
                descriptionKey: "market_item_description_120",
                iconName: "diamond.fill",
                price: 10000,
                currencyType: .won
            )
        ]
    }


    /// 마켓 아이템 구매 처리 (결과만 반환, 실제 구매 로직은 UserStateManager에서 수행)
    static func getPurchaseResult(for item: MarketItem) -> MarketPurchaseResult {
        switch item.type {
        case .gemPackage(count: let count, price: _):
            return .gemPackage(count: count)
        }
    }
}

/// 마켓 구매 결과
enum MarketPurchaseResult {
    case gemPackage(count: Int)
}
