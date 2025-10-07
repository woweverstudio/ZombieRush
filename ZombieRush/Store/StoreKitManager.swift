//
//  StoreKitManager.swift
//  ZombieRush
//
//  Created by StoreKit IAP Manager
//

import Foundation
import StoreKit
import SwiftUI

/// StoreKit IAP 관리자 (싱글톤)
@MainActor
@Observable
final class StoreKitManager {
    /// GemItem으로 변환된 상품들 (MarketView에서 사용)
    var gemItems: [GemItem] = []

    // MARK: - Private Properties
    private var updatesTask: Task<Void, Never>?
    private var unfinishedTask: Task<Void, Never>?

    // MARK: - Initialization
    private let useCaseFactory: UseCaseFactory
    private let alertManager: AlertManager

    init(useCaseFactory: UseCaseFactory, alertManager: AlertManager) {
        self.useCaseFactory = useCaseFactory
        self.alertManager = alertManager
    }

    // MARK: - Public Methods
    /// 로딩 뷰에서 데이터 로드가 다 끝나면 모니터링을 시작함.
    func startTransactionMonitoring() {
        // 실시간 트랜잭션 모니터링
        updatesTask = Task(priority: .background) {
            for await result in Transaction.updates {
                await self.handleTransaction(result)
            }
        }
        
        unfinishedTask = Task(priority: .background) {
            for await result in Transaction.unfinished {
                await self.handleTransaction(result)
            }
        }
    }

    /// 상품 로드
    func loadProducts() async -> Bool {
        do {
            // StoreKit에서 상품 로드
            let products = try await Product.products(for: ProductIDs.all)

            // GemItem으로 변환 (ID 기준 20, 55, 120 순서대로 정렬)
            let orderDict: [String: Int] = [
                ProductIDs.gem20: 0,
                ProductIDs.gem55: 1,
                ProductIDs.gem120: 2
            ]
            let sortedProducts = products.sorted { product1, product2 in
                let order1 = orderDict[product1.id] ?? Int.max
                let order2 = orderDict[product2.id] ?? Int.max
                return order1 < order2
            }
            
            self.gemItems = sortedProducts.map { GemItem(from: $0) }
            return true
        } catch {
            return false
        }
    }

    /// 상품 구매 (UI 트리거용)
    func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue

                // 트랜잭션 저장 (pending 상태)
                let transactionData = TransactionData(
                    transactionId: String(transaction.id),
                    productId: String(product.id),
                    purchaseDate: transaction.purchaseDate.ISO8601Format(),
                    jwsSignature: verification.jwsRepresentation
                )
                
                let success = await useCaseFactory.saveTransaction.execute(transactionData: transactionData)
                
                if success {
                    await handleTransaction(verification)
                }
            case .pending:
                alertManager.showToast(.iapPending)
                
            case .userCancelled:
                return
            
            @unknown default:
                return
            }

        } catch {
            alertManager.showError(.serverError)
        }
    }
    
    
    /// 트랜잭션 처리 (보상 지급은 여기서만!)
    private func handleTransaction(_ result: VerificationResult<StoreKit.Transaction>) async {        
        guard case .verified(let transaction) = result else { return }
        
        let transactionData = TransactionData(
            transactionId: String(transaction.id),
            productId: String(transaction.productID)
        )
        
        let request = AddGemRequest(transaction: transactionData)
        let response = await useCaseFactory.addGem.execute(request)
        
        if response.success {
            await transaction.finish()
        } else {
            alertManager.showError(.serverError)
        }
    }
}
