//
//  StatsStateManager.swift
//  ZombieRush
//
//  Created by Stats State Management with Supabase Integration
//

import Foundation
import Supabase
import SwiftUI

@Observable
class StatsStateManager {
    // MARK: - Properties
    var currentStats: Stats?
    var isLoading = false
    var error: Error?

    // Supabase 클라이언트
    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    // MARK: - Public Methods

    /// 플레이어 ID로 스탯 데이터 로드 또는 생성
    func loadOrCreateStats(playerID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 스탯 조회 시도
            if let existingStats = try await fetchStats(by: playerID) {
                currentStats = existingStats
                print("📊 Stats: 기존 스탯 로드 성공 - HP: \(existingStats.hpRecovery), Speed: \(existingStats.moveSpeed)")
            } else {
                // 2. 스탯이 없으면 새로 생성
                let newStats = Stats.defaultStats(for: playerID)
                currentStats = try await createStats(newStats)
                print("📊 Stats: 새 스탯 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("📊 Stats: 스탯 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 스탯 데이터 업데이트
    func updateStats(_ updates: Stats) async {
        guard let stats = currentStats else { return }

        do {
            currentStats = try await updateStatsInDatabase(stats)
            print("📊 Stats: 스탯 업데이트 성공")
        } catch {
            self.error = error
            print("📊 Stats: 스탯 업데이트 실패 - \(error.localizedDescription)")
        }
    }

    /// 특정 스탯 값 업데이트
    func updateStat(type: StatType, value: Int) async {
        guard var stats = currentStats else { return }

        switch type {
        case .hpRecovery:
            stats.hpRecovery = value
        case .moveSpeed:
            stats.moveSpeed = value
        case .energyRecovery:
            stats.energyRecovery = value
        case .attackSpeed:
            stats.attackSpeed = value
        case .totemCount:
            stats.totemCount = value
        }

        await updateStats(stats)
    }

    /// 스탯 값 증가
    func increaseStat(type: StatType, amount: Int = 1) async {
        guard var stats = currentStats else { return }

        switch type {
        case .hpRecovery:
            stats.hpRecovery += amount
        case .moveSpeed:
            stats.moveSpeed += amount
        case .energyRecovery:
            stats.energyRecovery += amount
        case .attackSpeed:
            stats.attackSpeed += amount
        case .totemCount:
            stats.totemCount += amount
        }

        await updateStats(stats)
    }

    /// 스탯 값 감소
    func decreaseStat(type: StatType, amount: Int = 1) async {
        guard var stats = currentStats else { return }

        switch type {
        case .hpRecovery:
            stats.hpRecovery = max(0, stats.hpRecovery - amount)
        case .moveSpeed:
            stats.moveSpeed = max(0, stats.moveSpeed - amount)
        case .energyRecovery:
            stats.energyRecovery = max(0, stats.energyRecovery - amount)
        case .attackSpeed:
            stats.attackSpeed = max(0, stats.attackSpeed - amount)
        case .totemCount:
            stats.totemCount = max(0, stats.totemCount - amount)
        }

        await updateStats(stats)
    }

    /// 스탯 초기화
    func resetStats() {
        guard var stats = currentStats else { return }
        stats.hpRecovery = 0
        stats.moveSpeed = 0
        stats.energyRecovery = 0
        stats.attackSpeed = 0
        stats.totemCount = 0

        Task {
            await updateStats(stats)
        }
    }

    /// 현재 스탯 정보 출력 (테스트용)
    func printCurrentStats() {
        if let stats = currentStats {
            print("📊 Stats: === 현재 스탯 정보 ===")
            print("📊 PlayerID: \(stats.playerId)")
            print("📊 HP 회복량: \(stats.hpRecovery)")
            print("📊 이동 속도: \(stats.moveSpeed)")
            print("📊 에너지 회복량: \(stats.energyRecovery)")
            print("📊 공격 속도: \(stats.attackSpeed)")
            print("📊 토템 개수: \(stats.totemCount)")
            print("📊 =================================")
        } else {
            print("📊 Stats: 현재 스탯 정보가 없습니다.")
        }

        if let error = error {
            print("📊 Stats: 마지막 에러 - \(error.localizedDescription)")
        }
    }

    /// 로그아웃 - 스탯 데이터 초기화
    func logout() {
        currentStats = nil
        error = nil
        print("📊 Stats: 로그아웃 완료")
    }

    // MARK: - Private Methods

    /// 스탯 조회
    private func fetchStats(by playerID: String) async throws -> Stats? {
        let stats: [Stats] = try await supabase
            .from("stats")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        return stats.first
    }

    /// 스탯 생성
    private func createStats(_ stats: Stats) async throws -> Stats {
        let createdStats: Stats = try await supabase
            .from("stats")
            .insert(stats)
            .select("*")
            .single()
            .execute()
            .value

        return createdStats
    }

    /// 스탯 업데이트
    private func updateStatsInDatabase(_ stats: Stats) async throws -> Stats {
        let updatedStats: Stats = try await supabase
            .from("stats")
            .update([
                "hp_recovery": String(stats.hpRecovery),
                "move_speed": String(stats.moveSpeed),
                "energy_recovery": String(stats.energyRecovery),
                "attack_speed": String(stats.attackSpeed),
                "totem_count": String(stats.totemCount)
            ])
            .eq("player_id", value: stats.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedStats
    }
}

/// 스탯 타입 열거형
enum StatType {
    case hpRecovery
    case moveSpeed
    case energyRecovery
    case attackSpeed
    case totemCount
}
