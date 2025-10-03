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
/// 특정 원소를 추가
struct AddSpiritUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: AddSpiritRequest) async -> AddSpiritResponse {
        // 현재 원소 정보 사용 (Repository의 currentSpirits)
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            ErrorManager.shared.report(.dataNotFound)
            return AddSpiritResponse(success: false, spirits: nil)
        }

        // 원소 수량 변경
        var updatedSpirits = currentSpirits
        switch request.spiritType {
        case .fire:
            updatedSpirits.fire += request.count
        case .ice:
            updatedSpirits.ice += request.count
        case .thunder:
            updatedSpirits.thunder += request.count
        case .dark:
            updatedSpirits.dark += request.count
        }

        do {
            let savedSpirits = try await spiritsRepository.updateSpirits(updatedSpirits)
            ToastManager.shared.show(.spiritPurchased(request.spiritType.localizedDisplayName))
            return AddSpiritResponse(success: true, spirits: savedSpirits)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return AddSpiritResponse(success: false, spirits: nil)
        }
        
    }
}
