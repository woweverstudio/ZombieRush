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
    let spirits: Spirits?
}

/// 정령 업데이트 UseCase
/// 정령 정보를 업데이트
struct UpdateSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: UpdateSpiritsRequest) async -> UpdateSpiritsResponse {
        do {
            let updatedSpirits = try await spiritsRepository.updateSpirits(request.spirits)
            return UpdateSpiritsResponse(spirits: updatedSpirits)
        } catch {
            ErrorManager.shared.report(.dataNotFound)
            return UpdateSpiritsResponse(spirits: nil)
        }
    }
}
