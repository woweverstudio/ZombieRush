//
//  AddGemUseCase.swift
//  ZombieRush
//
//  Created by Add Nemo gem UseCase
//

import Foundation

struct AddGemRequest {
    let transaction: TransactionData
}

struct AddGemResponse {
    let success: Bool
}

/// 젬 추가 UseCase
/// 젬을 추가
@MainActor
struct AddGemUseCase: UseCase {
    let userRepository: UserRepository
    let alertManager: AlertManager

    func execute(_ request: AddGemRequest) async -> AddGemResponse {
        // 현재 사용자 정보 사용 (Repository의 currentUser)
        guard let currentUser = userRepository.currentUser else {
            return AddGemResponse(success: false)
        }

        // 트랜잭션 완료 처리 및 gem 추가
        do {
            let newGemTotal = try await userRepository.completeGemPurchaseTransaction(transaction: request.transaction)

            // currentUser 업데이트 (gem 수량 동기화)
            let newUser = User(
                playerId: currentUser.playerId,
                nickname: currentUser.nickname,
                exp: currentUser.exp,
                gem: newGemTotal,
                remainingPoints: currentUser.remainingPoints,
                cheerBuffExpiresAt: currentUser.cheerBuffExpiresAt
            )
            
            userRepository.currentUser = newUser
            alertManager.showToast(.addGem(extractCount(from: request.transaction.productId)))
            return AddGemResponse(success: true)
        } catch {
            alertManager.showError(.serverError)
            return AddGemResponse(success: false)
        }
    }
    
    // 상품 ID에서 몇 개의 네모잼을 구매했는지 개수를 추출하는 함수
    private func extractCount(from text: String) -> Int {
        // 문자열 중 숫자만 필터링
        let digits = text.compactMap { $0.isNumber ? $0 : nil }
        
        // 숫자가 하나라도 있으면 문자열로 합침
        guard !digits.isEmpty else { return 0 }
        
        // Int로 변환 시도
        return Int(String(digits)) ?? 0
    }
}
