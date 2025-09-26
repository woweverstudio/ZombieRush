//
//  RefreshSpiritsUseCase.swift
//  ZombieRush
//
//  Created by Refresh Spirits UseCase
//

import Foundation

struct RefreshSpiritsRequest {
}

struct RefreshSpiritsResponse {
    let spirits: Spirits?
}

/// 정령 데이터 새로고침 UseCase
/// 최신 정령 정보를 가져옴
struct RefreshSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: RefreshSpiritsRequest) async -> RefreshSpiritsResponse {
        // currentSpirits의 playerID를 사용해서 서버에서 다시 조회
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshSpiritsResponse(spirits: nil)
        }

        guard let spirits = try? await spiritsRepository.getSpirits(by: currentSpirits.playerId) else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshSpiritsResponse(spirits: nil)
        }
        
        return RefreshSpiritsResponse(spirits: spirits)
    }
}
