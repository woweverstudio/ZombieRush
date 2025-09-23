//
//  StatsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Stats Data Access
//

import Foundation

/// 데이터 변경 콜백 타입
typealias StatsDataChangeCallback = () async -> Void

/// 스탯 데이터 액세스를 위한 Repository Protocol
protocol StatsRepository: AnyObject {
    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: StatsDataChangeCallback? { get set }
    /// 스탯 조회
    func getStats(by playerID: String) async throws -> Stats?

    /// 스탯 생성
    func createStats(_ stats: Stats) async throws -> Stats

    /// 스탯 업데이트
    func updateStats(_ stats: Stats) async throws -> Stats

    /// 스탯 업그레이드
    func upgradeStat(for playerID: String, statType: StatType) async throws -> Stats
}
