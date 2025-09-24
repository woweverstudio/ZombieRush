//
//  ResetSpiritsUseCase.swift
//  ZombieRush
//
//  Created by Reset Spirits UseCase
//

import Foundation

struct ResetSpiritsRequest {
}

struct ResetSpiritsResponse {
    let spirits: Spirits
}

/// 정령 리셋 UseCase
/// 정령을 기본 상태로 리셋
struct ResetSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: ResetSpiritsRequest) async throws -> ResetSpiritsResponse {
        // currentSpirits의 playerID를 사용해서 새로 생성
        guard let currentSpirits = spiritsRepository.currentSpirits else {
            throw NSError(domain: "ResetSpiritsUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "현재 정령 정보를 찾을 수 없습니다"])
        }

        let resetSpirits = Spirits.defaultSpirits(for: currentSpirits.playerId)
        let savedSpirits = try await spiritsRepository.updateSpirits(resetSpirits)

        print("🔥 SpiritsUseCase: 정령 리셋 완료 - 기본값으로 초기화")

        return ResetSpiritsResponse(spirits: savedSpirits)
    }
}
