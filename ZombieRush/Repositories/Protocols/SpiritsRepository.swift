//
//  SpiritsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Spirits Data Access
//

import Foundation

/// 원소 데이터 액세스를 위한 Repository Protocol
@MainActor
protocol SpiritsRepository: AnyObject {
    /// 원소 상태
    var currentSpirits: Spirits? { get set }

    /// 원소 데이터 조회
    func getSpirits(by playerID: String) async throws -> Spirits?

    /// 원소 데이터 생성
    func createSpirits(_ spirits: Spirits) async throws -> Spirits

    /// 원소 데이터 업데이트
    func updateSpirits(_ spirits: Spirits) async throws -> Spirits

    /// 네모열매를 소비하여 원소 교환 (트랜잭션)
    func exchangeFruitForSpirit(playerID: String, spiritType: String, amount: Int) async throws -> (Spirits, User)
}
