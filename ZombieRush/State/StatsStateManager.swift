//
//  StatsStateManager.swift
//  ZombieRush
//
//  Created by Stats State Management with Supabase Integration
//

import Foundation
import Supabase
import SwiftUI

/// 스탯 데이터와 상태를 관리하는 StateManager
/// View와 Repository 사이의 중간 계층으로 비즈니스 로직을 처리
@Observable
class StatsStateManager {
    // MARK: - Internal Properties (View에서 접근 가능)
    var currentStats: Stats?
    var isLoading = false
    var error: Error?

    // MARK: - Private Properties (내부 전용)
    private let statsRepository: StatsRepository
    private let userRepository: UserRepository

    init(statsRepository: StatsRepository, userRepository: UserRepository) {
        self.statsRepository = statsRepository
        self.userRepository = userRepository
    }

    // MARK: - Public Methods

    /// 플레이어 ID로 스탯 데이터 로드 또는 생성
    func loadOrCreateStats(playerID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 스탯 조회 시도
            if let existingStats = try await statsRepository.getStats(by: playerID) {
                currentStats = existingStats
                print("📊 Stats: 기존 스탯 로드 성공 - HP: \(existingStats.hpRecovery), Speed: \(existingStats.moveSpeed)")
            } else {
                // 2. 스탯이 없으면 새로 생성
                let newStats = Stats.defaultStats(for: playerID)
                currentStats = try await statsRepository.createStats(newStats)
                print("📊 Stats: 새 스탯 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("📊 Stats: 스탯 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 스탯 데이터 재조회 (최신 데이터 새로고침)
    func refreshStats() async {
        guard let playerId = currentStats?.playerId, !playerId.isEmpty else {
            print("📊 Stats: 재조회 실패 - playerID가 없습니다")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if let refreshedStats = try await statsRepository.getStats(by: playerId) {
                currentStats = refreshedStats
                print("📊 Stats: 스탯 데이터 재조회 성공")
            } else {
                print("📊 Stats: 재조회 실패 - 스탯 데이터를 찾을 수 없습니다")
            }
        } catch {
            self.error = error
            print("📊 Stats: 스탯 데이터 재조회 실패 - \(error.localizedDescription)")
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

    /// 로그아웃 - 스탯 데이터 초기화
    func logout() {
        currentStats = nil
        error = nil
        print("📊 Stats: 로그아웃 완료")
    }

    // MARK: - Stat Value Accessors (View에서 사용 가능)

    /// 특정 스탯 타입의 현재 값 조회
    func getCurrentStatValue(_ statType: StatType) -> Int {
        guard let stats = currentStats else { return 0 }

        switch statType {
        case .hpRecovery: return stats.hpRecovery
        case .moveSpeed: return stats.moveSpeed
        case .energyRecovery: return stats.energyRecovery
        case .attackSpeed: return stats.attackSpeed
        case .totemCount: return stats.totemCount
        }
    }

    // MARK: - Stats Upgrade Business Logic

    /// 스텟 업그레이드 (포인트 차감 포함)
    func upgradeStatWithPoints(_ statType: StatType) async -> Bool {
        guard let currentStats = currentStats else {
            print("📊 Stats: 업그레이드 실패 - 스탯 데이터가 없습니다")
            return false
        }

        // 포인트 차감
        let pointsConsumed = await consumePoints(1)
        if !pointsConsumed {
            print("❌ 포인트가 부족합니다")
            return false
        }

        // 스텟 업그레이드
        do {
            let updatedStats = try await statsRepository.upgradeStat(for: currentStats.playerId, statType: statType)
            self.currentStats = updatedStats
            // ✅ refresh는 콜백을 통해 자동으로 수행됨
            print("📊 Stats: \(statType.displayName) 업그레이드 완료 (+1)")
            return true
        } catch {
            self.error = error
            print("📊 Stats: \(statType.displayName) 업그레이드 실패 - \(error.localizedDescription)")
            return false
        }
    }

    /// 포인트 차감
    private func consumePoints(_ points: Int) async -> Bool {
        do {
            let updatedUser = try await userRepository.consumePoints(of: currentStats?.playerId ?? "", points: points)
            print("📊 Stats: 포인트 \(points)개 차감 완료 - 남은 포인트: \(updatedUser.remainingPoints)")
            return true
        } catch {
            self.error = error
            print("📊 Stats: 포인트 차감 실패 - \(error.localizedDescription)")
            return false
        }
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
