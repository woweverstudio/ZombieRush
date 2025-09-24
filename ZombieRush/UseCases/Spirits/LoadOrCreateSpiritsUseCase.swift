//
//  LoadOrCreateSpiritsUseCase.swift
//  ZombieRush
//
//  Created by Load or Create Spirits UseCase
//

import Foundation

struct LoadOrCreateSpiritsRequest {
    let playerID: String
}

struct LoadOrCreateSpiritsResponse {
    let spirits: Spirits
}

/// 정령 로드 또는 생성 UseCase
/// 플레이어 ID로 정령 데이터 로드 또는 생성
struct LoadOrCreateSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: LoadOrCreateSpiritsRequest) async throws -> LoadOrCreateSpiritsResponse {
        // 1. 정령 조회 시도
        if let existingSpirits = try await spiritsRepository.getSpirits(by: request.playerID) {
            print("🔥 SpiritsUseCase: 기존 정령 로드 성공 - 총 \(existingSpirits.totalCount)마리")
            return LoadOrCreateSpiritsResponse(spirits: existingSpirits)
        } else {
            // 2. 정령이 없으면 새로 생성
            let newSpirits = Spirits.defaultSpirits(for: request.playerID)
            let spirits = try await spiritsRepository.createSpirits(newSpirits)
            print("🔥 SpiritsUseCase: 새 정령 생성 성공 - 기본값으로 초기화")
            return LoadOrCreateSpiritsResponse(spirits: spirits)
        }
    }
}
