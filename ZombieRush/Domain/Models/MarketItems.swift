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
    case fruitPackage(count: Int, price: Int)
}

/// 마켓 아이템
struct MarketItem: Identifiable {
    let id = UUID()
    let type: MarketItemType
    let name: String
    let description: String
    let iconName: String
    let price: Int
    let currencyType: CurrencyType

    enum CurrencyType {
        case won
        case fruit
    }
}

// MARK: - Market Items Manager

/// 마켓 아이템 관리자
struct MarketItemsManager {
    /// 마켓 아이템 목록 (기본 아이템들)
    static var marketItems: [MarketItem] {
        [
            // 네모열매 패키지
            MarketItem(
                type: .fruitPackage(count: 20, price: 2000),
                name: "TODO: StoreKit에서 로드",
                description: "TODO: StoreKit에서 로드",
                iconName: "diamond.fill",
                price: 2000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 55, price: 5000),
                name: "TODO: StoreKit에서 로드",
                description: "TODO: StoreKit에서 로드",
                iconName: "diamond.fill",
                price: 5000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 110, price: 10000),
                name: "TODO: StoreKit에서 로드",
                description: "TODO: StoreKit에서 로드",
                iconName: "diamond.fill",
                price: 10000,
                currencyType: .won
            )
        ]
    }


    /// 마켓 아이템 구매 처리 (결과만 반환, 실제 구매 로직은 UserStateManager에서 수행)
    static func getPurchaseResult(for item: MarketItem) -> MarketPurchaseResult {
        switch item.type {
        case .fruitPackage(count: let count, price: _):
            return .fruitPackage(count: count)
        }
    }
}

/// 마켓 구매 결과
enum MarketPurchaseResult {
    case fruitPackage(count: Int)
}
