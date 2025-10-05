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
    private var currentEntitlementsTask: Task<Void, Never>?

    // MARK: - Initialization
    private let useCaseFactory: UseCaseFactory

    init(useCaseFactory: UseCaseFactory) {
        self.useCaseFactory = useCaseFactory
        setupTransactionObserver()
    }

    // MARK: - Public Methods

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

            print("✅ 상품 로드 완료: \(products.count)개")

        } catch {
            print("❌ 상품 로드 실패: \(error.localizedDescription)")
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
                print("✅ 구매 성공 (UI): \(product.displayName) - 트랜잭션 ID: \(transaction.id)")
                // finish()는 Transaction.updates 핸들러에서 호출

            case .userCancelled:
                print("ℹ️ 구매 취소됨: \(product.displayName)")
                throw StoreError.purchaseCancelled

            case .pending:
                print("⏳ 구매 대기 중: \(product.displayName)")
                throw StoreError.purchasePending

            @unknown default:
                throw StoreError.purchaseFailed
            }

        } catch let error as StoreError {
            self.currentError = error            
        } catch {
            self.currentError = .unknownProductType
        }
    }

    // MARK: - Private Methods

    /// 트랜잭션 업데이트 모니터링 설정
    private func setupTransactionObserver() {
        // 기존 Task 취소
        updatesTask?.cancel()
        currentEntitlementsTask?.cancel()

        // 실시간 트랜잭션 모니터링
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                await self.handleTransaction(result)
            }
        }

        // 현재 entitlements 확인 (앱 시작 시 복원용)
        currentEntitlementsTask = Task { [weak self] in
            for await result in Transaction.currentEntitlements {
                guard let self = self else { return }
                await self.handleTransaction(result)
            }
        }
    }

    /// 트랜잭션 처리 (보상 지급은 여기서만!)
    private func handleTransaction(_ result: VerificationResult<StoreKit.Transaction>) async {
        do {
            let transaction = try result.payloadValue

            print("🔄 트랜잭션 처리 시작: \(transaction.productID) (ID: \(transaction.id))")

            switch transaction.productType {
            case .consumable:
                // 소모품 구매 처리 (보상 지급)
                
                await deliverContent(for: transaction)
                await transaction.finish()

            case .nonConsumable:
                // 비소모품은 현재 지원하지 않음
                print("ℹ️ 비소모품 감지 (처리 생략): \(transaction.productID)")
                await transaction.finish()

            case .autoRenewable, .nonRenewable:
                // 구독은 현재 지원하지 않음
                print("ℹ️ 구독 감지 (처리 생략): \(transaction.productID)")
                await transaction.finish()

            default:
                print("❓ 알 수 없는 상품 타입: \(transaction.productID)")
                await transaction.finish()
            }

        } catch {
            print("❌ 트랜잭션 처리 에러: \(error.localizedDescription)")
        }
    }

    /// 컨텐츠 전달 (보상 지급)
    private func deliverContent(for transaction: StoreKit.Transaction) async {
        print("🎉 보상 지급: \(transaction.productID)")

        // 상품 ID에 따른 보상 지급
        let rewardAmount: Int
        switch transaction.productID {
        case StoreConstants.ProductIDs.gem20:
            rewardAmount = 20
        case StoreConstants.ProductIDs.gem55:
            rewardAmount = 55
        case StoreConstants.ProductIDs.gem120:
            rewardAmount = 120
        default:
            rewardAmount = 0
        }

        if rewardAmount > 0 {
            // TODO: UserRepository를 통해 젬 지급
            // 현재는 로그만 출력
            print("💎 \(rewardAmount) 젬 지급 완료!")
        }
    }
}
