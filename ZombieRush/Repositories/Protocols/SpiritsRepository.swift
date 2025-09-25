//
//  SpiritsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Spirits Data Access
//

import Foundation

/// 정령 데이터 액세스를 위한 Repository Protocol
@MainActor
protocol SpiritsRepository: AnyObject {
    /// 정령 상태
    var currentSpirits: Spirits? { get set }
    
    /// 정령 데이터 조회
    func getSpirits(by playerID: String) async throws -> Spirits?

    /// 정령 데이터 생성
    func createSpirits(_ spirits: Spirits) async throws -> Spirits

    /// 정령 데이터 업데이트
    func updateSpirits(_ spirits: Spirits) async throws -> Spirits
}
