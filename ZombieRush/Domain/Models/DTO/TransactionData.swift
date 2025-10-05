//
//  TransactionData.swift
//  ZombieRush
//
//  Created by Transaction Data Model
//

import Foundation

/// 트랜잭션 데이터 모델 (Supabase insert용)
struct TransactionData: Encodable {
    let transactionId: String
    let playerId: String
    let productId: String
    let status: String
    let purchaseDate: String?
    let jwsSignature: String?
    
    init(transactionId: String, playerId: String = "", productId: String, status: String = "pending", purchaseDate: String? = Date().ISO8601Format(), jwsSignature: String? = nil) {
        self.transactionId = transactionId
        self.playerId = playerId
        self.productId = productId
        self.status = status
        self.purchaseDate = purchaseDate
        self.jwsSignature = jwsSignature
    }

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case playerId = "player_id"
        case productId = "product_id"
        case status
        case purchaseDate = "purchase_date"
        case jwsSignature = "jws_signature"
    }
}
