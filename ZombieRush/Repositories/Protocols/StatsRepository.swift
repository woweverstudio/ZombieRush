//
//  StatsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Stats Data Access
//

import Foundation

/// 스탯 데이터 액세스를 위한 Repository Protocol
protocol StatsRepository {
    /// 스탯 조회
    func getStats(by playerID: String) async throws -> Stats?

    /// 스탯 생성
    func createStats(_ stats: Stats) async throws -> Stats

    /// 스탯 업데이트
    func updateStats(_ stats: Stats) async throws -> Stats

    /// 스탯 업그레이드
    func upgradeStat(for playerID: String, statType: StatType) async throws -> Stats
}
