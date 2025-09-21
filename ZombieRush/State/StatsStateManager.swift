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

    // MARK: - 디버깅 및 기타

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

    // MARK: - 스탯 업그레이드

    /// 스탯 업그레이드
    func upgradeStat(_ statType: StatType) async {
        guard var stats = currentStats else {
            print("📊 Stats: 업그레이드 실패 - 스탯 데이터가 없습니다")
            return
        }

        // 해당 스텟 값 증가
        switch statType {
        case .hpRecovery:
            stats.hpRecovery += 1
        case .moveSpeed:
            stats.moveSpeed += 1
        case .energyRecovery:
            stats.energyRecovery += 1
        case .attackSpeed:
            stats.attackSpeed += 1
        case .totemCount:
            stats.totemCount += 1
        }

        // 데이터베이스 업데이트 및 로컬 상태 업데이트
        do {
            let updatedStats = try await updateStatsInDatabase(stats)
            currentStats = updatedStats
            print("📊 Stats: \(statType.displayName) 업그레이드 완료 (+1)")
        } catch {
            self.error = error
            print("📊 Stats: \(statType.displayName) 업그레이드 실패 - \(error.localizedDescription)")
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
enum StatType: String, CaseIterable {
    case hpRecovery
    case moveSpeed
    case energyRecovery
    case attackSpeed
    case totemCount
}

// MARK: - StatType Extensions
extension StatType {
    var displayName: String {
        switch self {
        case .hpRecovery: return "HP 회복"
        case .moveSpeed: return "이동속도"
        case .energyRecovery: return "에너지 회복"
        case .attackSpeed: return "공격속도"
        case .totemCount: return "토템"
        }
    }

    var iconName: String {
        switch self {
        case .hpRecovery: return "heart.fill"
        case .moveSpeed: return "figure.run"
        case .energyRecovery: return "bolt.fill"
        case .attackSpeed: return "target"
        case .totemCount: return "building.columns"
        }
    }

    var color: Color {
        switch self {
        case .hpRecovery: return .red
        case .moveSpeed: return .green
        case .energyRecovery: return .blue
        case .attackSpeed: return .yellow
        case .totemCount: return .orange
        }
    }

    var description: String {
        switch self {
        case .hpRecovery: return "시간당 체력 회복량"
        case .moveSpeed: return "플레이어 이동 속도"
        case .energyRecovery: return "시간당 에너지 회복량"
        case .attackSpeed: return "무기 공격 속도"
        case .totemCount: return "배치 가능한 토템 수"
        }
    }
}
