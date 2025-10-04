//
//  LoadOrCreateElementsUseCase.swift
//  ZombieRush
//
//  Created by Load or Create Elements UseCase
//

import Foundation

struct LoadOrCreateElementsRequest {
    let playerID: String
}

struct LoadOrCreateElementsResponse {
    let elements: Elements
}

/// 원소 로드 또는 생성 UseCase
/// 플레이어 ID로 원소 데이터 로드 또는 생성
struct LoadOrCreateElementsUseCase: UseCase {
    let elementsRepository: ElementsRepository

    func execute(_ request: LoadOrCreateElementsRequest) async -> LoadOrCreateElementsResponse {
        do {
            // 1. 원소 조회 시도
            if let existingElements = try await elementsRepository.getElements(by: request.playerID) {
                return LoadOrCreateElementsResponse(elements: existingElements)
            } else {
                // 2. 원소가 없으면 새로 생성
                let newElements = Elements.defaultElements(for: request.playerID)
                let elements = try await elementsRepository.createElements(newElements)
                return LoadOrCreateElementsResponse(elements: elements)
            }
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return LoadOrCreateElementsResponse(elements: Elements(playerId: ""))
        }
        
    }
}
