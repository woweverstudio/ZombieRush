//
//  UpdateElementsUseCase.swift
//  ZombieRush
//
//  Created by Update Elements UseCase
//

import Foundation

struct UpdateElementsRequest {
    let elements: Elements
}

struct UpdateElementsResponse {
    let elements: Elements?
}

/// 원소 업데이트 UseCase
/// 원소 정보를 업데이트
struct UpdateElementsUseCase: UseCase {
    let elementsRepository: ElementsRepository

    func execute(_ request: UpdateElementsRequest) async -> UpdateElementsResponse {
        do {
            let updatedElements = try await elementsRepository.updateElements(request.elements)
            return UpdateElementsResponse(elements: updatedElements)
        } catch {
            ErrorManager.shared.report(.dataNotFound)
            return UpdateElementsResponse(elements: nil)
        }
    }
}
