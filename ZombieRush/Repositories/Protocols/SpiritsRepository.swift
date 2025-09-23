//
//  SpiritsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Spirits Data Access
//

import Foundation

/// 데이터 변경 콜백 타입
typealias SpiritsDataChangeCallback = () async -> Void

/// 정령 데이터 액세스를 위한 Repository Protocol
protocol SpiritsRepository: AnyObject {
    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: SpiritsDataChangeCallback? { get set }
    /// 정령 데이터 조회
    func getSpirits(by playerID: String) async throws -> Spirits?

    /// 정령 데이터 생성
    func createSpirits(_ spirits: Spirits) async throws -> Spirits

    /// 정령 데이터 업데이트
    func updateSpirits(_ spirits: Spirits) async throws -> Spirits

    /// 정령 추가
    func addSpirit(for playerID: String, spiritType: SpiritType, count: Int) async throws -> Spirits
}
