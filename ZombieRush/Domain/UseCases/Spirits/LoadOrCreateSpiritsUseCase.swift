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

/// 원소 로드 또는 생성 UseCase
/// 플레이어 ID로 원소 데이터 로드 또는 생성
struct LoadOrCreateSpiritsUseCase: UseCase {
    let spiritsRepository: SpiritsRepository

    func execute(_ request: LoadOrCreateSpiritsRequest) async -> LoadOrCreateSpiritsResponse {
        do {
            // 1. 원소 조회 시도
            if let existingSpirits = try await spiritsRepository.getSpirits(by: request.playerID) {
                return LoadOrCreateSpiritsResponse(spirits: existingSpirits)
            } else {
                // 2. 원소가 없으면 새로 생성
                let newSpirits = Spirits.defaultSpirits(for: request.playerID)
                let spirits = try await spiritsRepository.createSpirits(newSpirits)
                return LoadOrCreateSpiritsResponse(spirits: spirits)
            }
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return LoadOrCreateSpiritsResponse(spirits: Spirits(playerId: ""))
        }
        
    }
}
