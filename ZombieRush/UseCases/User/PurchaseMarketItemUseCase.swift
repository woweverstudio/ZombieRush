//
//  PurchaseMarketItemUseCase.swift
//  ZombieRush
//
//  Created by Purchase Market Item UseCase
//

import Foundation

struct PurchaseMarketItemRequest {
    let item: MarketItem
}

struct PurchaseMarketItemResponse {
    let success: Bool
    let user: User?
}

/// 마켓 아이템 구매 UseCase
/// 마켓 아이템을 구매하고 효과를 적용
struct PurchaseMarketItemUseCase: UseCase {
    let userRepository: UserRepository

    func execute(_ request: PurchaseMarketItemRequest) async throws -> PurchaseMarketItemResponse {
        let result = MarketItemsManager.getPurchaseResult(for: request.item)

        switch result {
        case .fruitPackage(count: let count):
            // 네모열매 패키지 구매
            print("📱 UserUseCase: 네모열매 \(count)개 패키지 구매 (₩\(request.item.price))")

            let addFruitsRequest = AddNemoFruitsRequest(fruitsToAdd: count)
            let addFruitsUseCase = AddNemoFruitsUseCase(userRepository: userRepository)
            let response = try await addFruitsUseCase.execute(addFruitsRequest)

            return PurchaseMarketItemResponse(success: true, user: response.user)

        case .cheerBuff(days: let days):
            // 네모의 응원 구매
            print("📱 UserUseCase: 네모의 응원 \(days)일 구매 (₩\(request.item.price))")
            let duration = TimeInterval(days * 24 * 60 * 60) // days를 초로 변환

            let purchaseBuffRequest = PurchaseCheerBuffRequest(duration: duration)
            let purchaseBuffUseCase = PurchaseCheerBuffUseCase(userRepository: userRepository)
            let response = try await purchaseBuffUseCase.execute(purchaseBuffRequest)

            return PurchaseMarketItemResponse(success: response.success, user: response.user)
        }
    }
}
