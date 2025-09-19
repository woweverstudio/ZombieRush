//
//  SpiritsStateManager.swift
//  ZombieRush
//
//  Created by Spirits State Management with Supabase Integration
//

import Foundation
import Supabase
import SwiftUI

@Observable
class SpiritsStateManager {
    // MARK: - Properties
    var currentSpirits: Spirits?
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

    /// 플레이어 ID로 정령 데이터 로드 또는 생성
    func loadOrCreateSpirits(playerID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 정령 조회 시도
            if let existingSpirits = try await fetchSpirits(by: playerID) {
                currentSpirits = existingSpirits
                print("🔥 Spirits: 기존 정령 로드 성공 - 총 \(existingSpirits.totalCount)마리")
            } else {
                // 2. 정령이 없으면 새로 생성
                let newSpirits = Spirits.defaultSpirits(for: playerID)
                currentSpirits = try await createSpirits(newSpirits)
                print("🔥 Spirits: 새 정령 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("🔥 Spirits: 정령 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 정령 데이터 업데이트
    func updateSpirits(_ updates: Spirits) async {
        guard let spirits = currentSpirits else { return }

        do {
            currentSpirits = try await updateSpiritsInDatabase(spirits)
            print("🔥 Spirits: 정령 업데이트 성공")
        } catch {
            self.error = error
            print("🔥 Spirits: 정령 업데이트 실패 - \(error.localizedDescription)")
        }
    }

    /// 특정 정령 타입 수량 업데이트
    func updateSpirit(type: SpiritType, count: Int) async {
        guard var spirits = currentSpirits else { return }

        switch type {
        case .fire:
            spirits.fire = count
        case .ice:
            spirits.ice = count
        case .lightning:
            spirits.lightning = count
        case .dark:
            spirits.dark = count
        }

        await updateSpirits(spirits)
    }

    /// 특정 정령 타입 수량 증가
    func increaseSpirit(type: SpiritType, amount: Int = 1) async {
        guard var spirits = currentSpirits else { return }

        switch type {
        case .fire:
            spirits.fire += amount
        case .ice:
            spirits.ice += amount
        case .lightning:
            spirits.lightning += amount
        case .dark:
            spirits.dark += amount
        }

        await updateSpirits(spirits)
    }

    /// 특정 정령 타입 수량 감소
    func decreaseSpirit(type: SpiritType, amount: Int = 1) async {
        guard var spirits = currentSpirits else { return }

        switch type {
        case .fire:
            spirits.fire = max(0, spirits.fire - amount)
        case .ice:
            spirits.ice = max(0, spirits.ice - amount)
        case .lightning:
            spirits.lightning = max(0, spirits.lightning - amount)
        case .dark:
            spirits.dark = max(0, spirits.dark - amount)
        }

        await updateSpirits(spirits)
    }

    /// 모든 정령 수량 증가 (보너스 등)
    func increaseAllSpirits(amount: Int = 1) async {
        guard var spirits = currentSpirits else { return }

        spirits.fire += amount
        spirits.ice += amount
        spirits.lightning += amount
        spirits.dark += amount

        await updateSpirits(spirits)
    }

    /// 정령 초기화
    func resetSpirits() {
        guard var spirits = currentSpirits else { return }
        spirits.fire = 0
        spirits.ice = 0
        spirits.lightning = 0
        spirits.dark = 0

        Task {
            await updateSpirits(spirits)
        }
    }

    /// 현재 정령 정보 출력 (테스트용)
    func printCurrentSpirits() {
        if let spirits = currentSpirits {
            print("🔥 Spirits: === 현재 정령 정보 ===")
            print("🔥 PlayerID: \(spirits.playerId)")
            print("🔥 불 정령: \(spirits.fire)")
            print("🔥 얼음 정령: \(spirits.ice)")
            print("🔥 번개 정령: \(spirits.lightning)")
            print("🔥 어둠 정령: \(spirits.dark)")
            print("🔥 총 정령 수: \(spirits.totalCount)")
            print("🔥 =================================")
        } else {
            print("🔥 Spirits: 현재 정령 정보가 없습니다.")
        }

        if let error = error {
            print("🔥 Spirits: 마지막 에러 - \(error.localizedDescription)")
        }
    }

    /// 로그아웃 - 정령 데이터 초기화
    func logout() {
        currentSpirits = nil
        error = nil
        print("🔥 Spirits: 로그아웃 완료")
    }

    // MARK: - Private Methods

    /// 정령 조회
    private func fetchSpirits(by playerID: String) async throws -> Spirits? {
        let spirits: [Spirits] = try await supabase
            .from("spirits")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        return spirits.first
    }

    /// 정령 생성
    private func createSpirits(_ spirits: Spirits) async throws -> Spirits {
        let createdSpirits: Spirits = try await supabase
            .from("spirits")
            .insert(spirits)
            .select("*")
            .single()
            .execute()
            .value

        return createdSpirits
    }

    /// 정령 업데이트
    private func updateSpiritsInDatabase(_ spirits: Spirits) async throws -> Spirits {
        let updatedSpirits: Spirits = try await supabase
            .from("spirits")
            .update([
                "fire": String(spirits.fire),
                "ice": String(spirits.ice),
                "lightning": String(spirits.lightning),
                "dark": String(spirits.dark)
            ])
            .eq("player_id", value: spirits.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedSpirits
    }
}

/// 정령 타입 열거형
enum SpiritType {
    case fire
    case ice
    case lightning
    case dark
}
