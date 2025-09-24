//
//  IncreaseAllSpiritsUseCase.swift
//  ZombieRush
//
//  Created by Increase All Spirits UseCase
//

import Foundation

struct IncreaseAllSpiritsRequest {
    let count: Int
}

struct IncreaseAllSpiritsResponse {
    let spirits: Spirits
}

/// 모든 정령 증가 UseCase
/// 모든 정령 타입의 수량을 증가
struct IncreaseAllSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: IncreaseAllSpiritsRequest) async throws -> IncreaseAllSpiritsResponse {
        // 현재 정령 정보 사용 (Repository의 currentSpirits)
        guard let currentSpirits = spiritsRepository.currentSpirits else {
            throw NSError(domain: "IncreaseAllSpiritsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "정령 정보를 찾을 수 없습니다"])
        }

        // 모든 정령 타입 수량 증가
        var updatedSpirits = currentSpirits
        updatedSpirits.fire += request.count
        updatedSpirits.ice += request.count
        updatedSpirits.lightning += request.count
        updatedSpirits.dark += request.count

        let savedSpirits = try await spiritsRepository.updateSpirits(updatedSpirits)

        print("🔥 SpiritsUseCase: 모든 정령 \(request.count)개씩 증가 - 총 \(savedSpirits.totalCount)마리")

        return IncreaseAllSpiritsResponse(spirits: savedSpirits)
    }
}
