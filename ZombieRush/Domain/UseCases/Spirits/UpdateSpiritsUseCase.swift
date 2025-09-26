//
//  UpdateSpiritsUseCase.swift
//  ZombieRush
//
//  Created by Update Spirits UseCase
//

import Foundation

struct UpdateSpiritsRequest {
    let spirits: Spirits
}

struct UpdateSpiritsResponse {
    let spirits: Spirits
}

/// 정령 업데이트 UseCase
/// 정령 정보를 업데이트
struct UpdateSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: UpdateSpiritsRequest) async throws -> UpdateSpiritsResponse {
        let updatedSpirits = try await spiritsRepository.updateSpirits(request.spirits)
        print("🔥 SpiritsUseCase: 정령 업데이트 성공")
        return UpdateSpiritsResponse(spirits: updatedSpirits)
    }
}
