//
//  RefreshElementsUseCase.swift
//  ZombieRush
//
//  Created by Refresh Elements UseCase
//

import Foundation

struct RefreshElementsRequest {
}

struct RefreshElementsResponse {
    let elements: Elements?
}

/// 원소 데이터 새로고침 UseCase
/// 최신 원소 정보를 가져옴
struct RefreshElementsUseCase: UseCase {
    let elementsRepository: ElementsRepository

    func execute(_ request: RefreshElementsRequest) async -> RefreshElementsResponse {
        // currentElements의 playerID를 사용해서 서버에서 다시 조회
        guard let currentElements = await elementsRepository.currentElements else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshElementsResponse(elements: nil)
        }

        guard let elements = try? await elementsRepository.getElements(by: currentElements.playerId) else {
            ErrorManager.shared.report(.dataNotFound)
            return RefreshElementsResponse(elements: nil)
        }
        
        return RefreshElementsResponse(elements: elements)
    }
}
