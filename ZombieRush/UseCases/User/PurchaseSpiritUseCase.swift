//
//  PurchaseSpiritUseCase.swift
//  ZombieRush
//
//  Created by Purchase Spirit UseCase
//

import Foundation

struct PurchaseSpiritRequest {
    let spiritType: SpiritType
    let quantity: Int
}

struct PurchaseSpiritResponse {
    let success: Bool
    let user: User?
}

/// 정령 구매 UseCase
/// 정령을 구매하고 네모열매를 소비하며 정령 수량을 업데이트
struct PurchaseSpiritUseCase: UseCase {
    let userRepository: UserRepository
    let spiritsRepository: SpiritsRepository

    func execute(_ request: PurchaseSpiritRequest) async throws -> PurchaseSpiritResponse {
        // 네모열매 차감
        let consumeFruitsRequest = ConsumeNemoFruitsRequest(fruitsToConsume: request.quantity)
        let consumeFruitsUseCase = ConsumeNemoFruitsUseCase(userRepository: userRepository)
        let consumeResponse = try await consumeFruitsUseCase.execute(consumeFruitsRequest)

        if !consumeResponse.success {
            print("📱 UserUseCase: 정령 구매 실패 - 네모열매 차감 실패")
            return PurchaseSpiritResponse(success: false, user: consumeResponse.user)
        }

        guard let currentUser = consumeResponse.user else {
            return PurchaseSpiritResponse(success: false, user: nil)
        }

        // 현재 정령 정보 사용 (Repository의 currentSpirits)
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            print("📱 UserUseCase: 정령 구매 실패 - 정령 정보를 찾을 수 없습니다")
            return PurchaseSpiritResponse(success: false, user: currentUser)
        }

        // 정령 수량 변경
        var updatedSpirits = currentSpirits
        switch request.spiritType {
        case .fire:
            updatedSpirits.fire += request.quantity
        case .ice:
            updatedSpirits.ice += request.quantity
        case .lightning:
            updatedSpirits.lightning += request.quantity
        case .dark:
            updatedSpirits.dark += request.quantity
        }

        // DB 업데이트
        _ = try await spiritsRepository.updateSpirits(updatedSpirits)

        print("🔥 UserUseCase: \(request.spiritType.displayName) \(request.quantity)마리 구매 완료")
        return PurchaseSpiritResponse(success: true, user: currentUser)
    }
}
