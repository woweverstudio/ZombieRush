//
//  AddElementUseCase.swift
//  ZombieRush
//
//  Created by Add Element UseCase
//

import Foundation

struct AddElementRequest {
    let elementType: ElementType
    let count: Int
}

struct AddElementResponse {
    let success: Bool
    let elements: Elements?
}

/// 원소 추가 UseCase
/// 네모잼을 소비하여 특정 원소를 추가 (트랜잭션)
@MainActor
struct AddElementUseCase: UseCase {
    let elementsRepository: ElementsRepository
    let userRepository: UserRepository
    let alertManager: AlertManager

    func execute(_ request: AddElementRequest) async -> AddElementResponse {
        // 현재 사용자 정보 확인
        guard let currentUser = userRepository.currentUser else {
            return AddElementResponse(success: false, elements: nil)
        }

        do {
            // 트랜잭션으로 네모잼 차감 및 원소 증가
            let (updatedElements, updatedUser) = try await elementsRepository.exchangeGemForElement(
                playerID: currentUser.playerId,
                elementType: request.elementType.id,
                amount: request.count
            )

            // Repository 업데이트
            elementsRepository.currentElements = updatedElements
            userRepository.currentUser = updatedUser
            
            let element = request.elementType
            alertManager.showToast(.addElement(element.iconName, element.color, element.localizedDisplayName, request.count))
            return AddElementResponse(success: true, elements: updatedElements)
        } catch {
            // 네모잼 부족 등의 에러 처리
            alertManager.showError(.serverError)
            return AddElementResponse(success: false, elements: nil)
        }
    }
}
