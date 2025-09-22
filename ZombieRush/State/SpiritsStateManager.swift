//
//  SpiritsStateManager.swift
//  ZombieRush
//
//  Created by Spirits State Management with Supabase Integration
//

import Foundation
import SwiftUI

@Observable
class SpiritsStateManager {
    // MARK: - Internal Properties (View에서 접근 가능)
    var currentSpirits: Spirits?
    var isLoading = false
    var error: Error?

    // MARK: - Private Properties (내부 전용)
    private let spiritsRepository: SpiritsRepository
    
    init(spiritsRepository: SpiritsRepository) {
        self.spiritsRepository = spiritsRepository
    }
    
    // MARK: - Public Methods
    
    /// 플레이어 ID로 정령 데이터 로드 또는 생성
    func loadOrCreateSpirits(playerID: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. 정령 조회 시도
            if let existingSpirits = try await spiritsRepository.getSpirits(by: playerID) {
                currentSpirits = existingSpirits
                print("🔥 Spirits: 기존 정령 로드 성공 - 총 \(existingSpirits.totalCount)마리")
            } else {
                // 2. 정령이 없으면 새로 생성
                let newSpirits = Spirits.defaultSpirits(for: playerID)
                currentSpirits = try await spiritsRepository.createSpirits(newSpirits)
                print("🔥 Spirits: 새 정령 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("🔥 Spirits: 정령 로드/생성 실패 - \(error.localizedDescription)")
        }
    }
    
    /// 정령 데이터 업데이트
    func updateSpirits(_ updates: Spirits) async {
        do {
            currentSpirits = try await spiritsRepository.updateSpirits(updates)
            print("🔥 Spirits: 정령 업데이트 성공")
        } catch {
            self.error = error
            print("🔥 Spirits: 정령 업데이트 실패 - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods

    /// 특정 정령 타입의 현재 수량 조회
    private func getCurrentCount(for spiritType: SpiritType) -> Int {
        guard let spirits = currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }
    
    /// 모든 정령 수량 증가 (보너스 등)
    func increaseAllSpirits(amount: Int = 1) async {
        guard let currentSpirits = currentSpirits else { return }
        
        do {
            var updatedSpirits = currentSpirits
            updatedSpirits.fire += amount
            updatedSpirits.ice += amount
            updatedSpirits.lightning += amount
            updatedSpirits.dark += amount
            
            self.currentSpirits = try await spiritsRepository.updateSpirits(updatedSpirits)
            print("🔥 Spirits: 모든 정령 \(amount)개씩 증가 완료")
        } catch {
            self.error = error
            print("🔥 Spirits: 모든 정령 증가 실패 - \(error.localizedDescription)")
        }
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
    
    /// 정령 수량 변경 (양수: 증가, 음수: 감소)
    func addSpirit(_ spiritType: SpiritType, count: Int) async {
        guard let currentSpirits = currentSpirits else {
            print("🔥 Spirits: 정령 변경 실패 - 데이터가 없습니다")
            return
        }

        do {
            let updatedSpirits = try await spiritsRepository.addSpirit(
                for: currentSpirits.playerId,
                spiritType: spiritType,
                count: count
            )
            self.currentSpirits = updatedSpirits

            let action = count > 0 ? "추가" : "감소"
            print("🔥 Spirits: \(spiritType.displayName) \(abs(count))마리 \(action) 완료")
        } catch {
            self.error = error
            let action = count > 0 ? "추가" : "감소"
            print("🔥 Spirits: \(spiritType.displayName) \(action) 실패 - \(error.localizedDescription)")
        }
    }
    
    /// 로그아웃 - 정령 데이터 초기화
    func logout() {
        currentSpirits = nil
        error = nil
        print("🔥 Spirits: 로그아웃 완료")
    }
}

