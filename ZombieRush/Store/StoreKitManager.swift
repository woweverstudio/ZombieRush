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
    /// 캐시된 상품들
    var products: [Product] = []

    /// GemItem으로 변환된 상품들 (MarketView에서 사용)
    var gemItems: [GemItem] = []
    
    /// 에러 상태
    var currentError: StoreError?  = nil
    
    /// 로딩 상태
    var isLoading = false

    // MARK: - Private Properties

    private var updatesTask: Task<Void, Never>?
    private var unfinishedTask: Task<Void, Never>?

    // MARK: - Initialization
    private let useCaseFactory: UseCaseFactory

    init(useCaseFactory: UseCaseFactory) {
        self.useCaseFactory = useCaseFactory
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
    func loadProducts() async throws {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // StoreKit에서 상품 로드
            let products = try await Product.products(for: StoreConstants.ProductIDs.all)

            // 캐시에 저장
            self.products = products

            // GemItem으로 변환 (ID 기준 20, 55, 120 순서대로 정렬)
            let orderDict: [String: Int] = [
                StoreConstants.ProductIDs.gem20: 0,
                StoreConstants.ProductIDs.gem55: 1,
                StoreConstants.ProductIDs.gem120: 2
            ]
            let sortedProducts = products.sorted { product1, product2 in
                let order1 = orderDict[product1.id] ?? Int.max
                let order2 = orderDict[product2.id] ?? Int.max
                return order1 < order2
            }
            self.gemItems = sortedProducts.map { GemItem(from: $0) }
        } catch {
            throw StoreError.productLoadFailed
        }
    }

    /// 상품 구매 (UI 트리거용)
    func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // UI 피드백만 - 실제 보상은 Transaction.updates에서 처리
                let transaction = try verification.payloadValue

                // 트랜잭션 저장 (pending 상태)
                let transactionData = TransactionData(
                    transactionId: String(transaction.id),
                    productId: String(product.id),
                    purchaseDate: transaction.purchaseDate.ISO8601Format(),
                    jwsSignature: verification.jwsRepresentation
                )
                
                try await useCaseFactory.saveTransaction.execute(transactionData: transactionData)
                
                await handleTransaction(verification)

            case .userCancelled:
                throw StoreError.purchaseCancelled

            case .pending:
                throw StoreError.purchasePending
            @unknown default:
                return
            }

        } catch let error as StoreError {
            self.currentError = error            
        } catch {
            self.currentError = .unknownProductType
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
        }
    }
}
