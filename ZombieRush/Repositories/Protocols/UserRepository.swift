//
//  UserRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for User Data Access
//

import Foundation

/// 사용자 데이터 액세스를 위한 Repository Protocol
protocol UserRepository {
    /// 사용자 조회
    func getUser(by playerID: String) async throws -> User?

    /// 사용자 생성
    func createUser(_ user: User) async throws -> User

    /// 사용자 업데이트
    func updateUser(_ user: User) async throws -> User

    /// 경험치 추가 및 레벨업 처리
    func addExperience(to playerID: String, exp: Int) async throws -> User

    /// 네모열매 추가
    func addNemoFruits(to playerID: String, count: Int) async throws -> User

    /// 포인트 소비
    func consumePoints(of playerID: String, points: Int) async throws -> User

    /// 네모의 응원 구매
    func purchaseCheerBuff(for playerID: String, duration: TimeInterval) async throws -> User
}
