//
//  AddSpiritUseCase.swift
//  ZombieRush
//
//  Created by Add Spirit UseCase
//

import Foundation

struct AddSpiritRequest {
    let spiritType: SpiritType
    let count: Int
}

struct AddSpiritResponse {
    let success: Bool
    let spirits: Spirits?
}

/// 원소 추가 UseCase
/// 네모열매를 소비하여 특정 원소를 추가 (트랜잭션)
@MainActor
struct AddSpiritUseCase: UseCase {
    let spiritsRepository: SpiritsRepository
    let userRepository: UserRepository

    func execute(_ request: AddSpiritRequest) async -> AddSpiritResponse {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {
            ErrorManager.shared.report(.userNotFound)
            return AddSpiritResponse(success: false, spirits: nil)
        }

        do {
            // 트랜잭션으로 네모열매 차감 및 원소 증가
            let (updatedSpirits, updatedUser) = try await spiritsRepository.exchangeFruitForSpirit(
                playerID: currentUser.playerId,
                spiritType: request.spiritType.id,
                amount: request.count
            )

            // Repository 업데이트
            spiritsRepository.currentSpirits = updatedSpirits
            userRepository.currentUser = updatedUser

            ToastManager.shared.show(.spiritPurchased("\(request.spiritType.localizedDisplayName) x\(request.count)"))
            return AddSpiritResponse(success: true, spirits: updatedSpirits)
        } catch {
            // 네모열매 부족 등의 에러 처리\
            ErrorManager.shared.report(.databaseRequestFailed)
            return AddSpiritResponse(success: false, spirits: nil)
        }
    }
}
