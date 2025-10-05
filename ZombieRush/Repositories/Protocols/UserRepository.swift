//
//  UserRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for User Data Access
//

import Foundation

/// 사용자 데이터 액세스를 위한 Repository Protocol
@MainActor
protocol UserRepository: AnyObject {
    /// 유저 상태
    var currentUser: User? { get set }
    
    /// 사용자 조회
    func getUser(by playerID: String) async throws -> User?

    /// 사용자 생성
    func createUser(_ user: User) async throws -> User

    /// 사용자 업데이트
    func updateUser(_ user: User) async throws -> User

    /// 게임 데이터 전체 로드 (RPC)
    func loadGameData(playerID: String, nickname: String) async throws -> GameData

    /// 네모잼 구매 트랜잭션 완료 처리 (RPC)
    func completeGemPurchaseTransaction(transaction: TransactionData) async throws -> Int
}
