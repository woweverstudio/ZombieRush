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
    case cheerBuff(days: Int, price: Int)
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
                name: "네모열매 20개",
                description: "네모열매 20개를 즉시 충전",
                iconName: "diamond.fill",
                price: 2000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 55, price: 5000),
                name: "네모열매 55개",
                description: "네모열매 55개를 즉시 충전 (약 15% 보너스)",
                iconName: "diamond.fill",
                price: 5000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 110, price: 10000),
                name: "네모열매 110개",
                description: "네모열매 110개를 즉시 충전 (약 10% 보너스)",
                iconName: "diamond.fill",
                price: 10000,
                currencyType: .won
            ),
            // 네모의 응원
            MarketItem(
                type: .cheerBuff(days: 3, price: 3000),
                name: "네모의 응원",
                description: "3일간 네모의 응원을 받습니다",
                iconName: "star.circle.fill",
                price: 3000,
                currencyType: .won
            )
        ]
    }


    /// 마켓 아이템 구매 처리 (결과만 반환, 실제 구매 로직은 UserStateManager에서 수행)
    static func getPurchaseResult(for item: MarketItem) -> MarketPurchaseResult {
        switch item.type {
        case .fruitPackage(count: let count, price: _):
            return .fruitPackage(count: count)
        case .cheerBuff(days: let days, price: _):
            return .cheerBuff(days: days)
        }
    }
}

/// 마켓 구매 결과
enum MarketPurchaseResult {
    case fruitPackage(count: Int)
    case cheerBuff(days: Int)
}
