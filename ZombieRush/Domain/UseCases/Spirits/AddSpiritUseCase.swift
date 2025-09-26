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
    let spirits: Spirits
}

/// 정령 추가 UseCase
/// 특정 정령을 추가
struct AddSpiritUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: AddSpiritRequest) async throws -> AddSpiritResponse {
        // 현재 정령 정보 사용 (Repository의 currentSpirits)
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            throw NSError(domain: "AddSpiritUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "정령 정보를 찾을 수 없습니다"])
        }

        // 정령 수량 변경
        var updatedSpirits = currentSpirits
        switch request.spiritType {
        case .fire:
            updatedSpirits.fire += request.count
        case .ice:
            updatedSpirits.ice += request.count
        case .lightning:
            updatedSpirits.lightning += request.count
        case .dark:
            updatedSpirits.dark += request.count
        }

        let savedSpirits = try await spiritsRepository.updateSpirits(updatedSpirits)

        // 추가된 후의 총 수량 계산
        let newCount = switch request.spiritType {
        case .fire: savedSpirits.fire
        case .ice: savedSpirits.ice
        case .lightning: savedSpirits.lightning
        case .dark: savedSpirits.dark
        }
        print("🔥 SpiritsUseCase: \(request.spiritType.displayName) 정령 \(request.count)개 추가 - 총 \(newCount)개")

        return AddSpiritResponse(spirits: savedSpirits)
    }
}
