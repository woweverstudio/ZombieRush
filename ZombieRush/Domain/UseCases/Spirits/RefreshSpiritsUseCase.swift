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
    let spirits: Spirits
}

/// 정령 데이터 새로고침 UseCase
/// 최신 정령 정보를 가져옴
struct RefreshSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: RefreshSpiritsRequest) async throws -> RefreshSpiritsResponse {
        // currentSpirits의 playerID를 사용해서 서버에서 다시 조회
        guard let currentSpirits = await spiritsRepository.currentSpirits else {
            throw NSError(domain: "RefreshSpiritsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 정령 정보가 없습니다"])
        }

        guard let spirits = try await spiritsRepository.getSpirits(by: currentSpirits.playerId) else {
            throw NSError(domain: "RefreshSpiritsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "정령 정보를 찾을 수 없습니다"])
        }
        print("🔥 SpiritsUseCase: 정령 새로고침 성공")
        return RefreshSpiritsResponse(spirits: spirits)
    }
}
