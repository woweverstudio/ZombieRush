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
    // MARK: - Properties
    var currentSpirits: Spirits?
    var isLoading = false
    var error: Error?
    
    // Repository
    private let spiritsRepository: SpiritsRepository
    
    init(spiritsRepository: SpiritsRepository = SupabaseSpiritsRepository()) {
        self.spiritsRepository = spiritsRepository
    }
    
    // Legacy init for backward compatibility
    convenience init() {
        self.init(spiritsRepository: SupabaseSpiritsRepository())
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
    
    /// 특정 정령 타입 수량 업데이트
    func updateSpirit(type: SpiritType, count: Int) async {
        guard let currentSpirits = currentSpirits else { return }
        
        do {
            self.currentSpirits = try await spiritsRepository.addSpirit(
                for: currentSpirits.playerId,
                spiritType: type,
                count: count - getCurrentCount(for: type) // 차이만큼 추가
            )
            print("🔥 Spirits: \(type.displayName) 수량 업데이트 완료")
        } catch {
            self.error = error
            print("🔥 Spirits: \(type.displayName) 수량 업데이트 실패 - \(error.localizedDescription)")
        }
    }
    
    private func getCurrentCount(for spiritType: SpiritType) -> Int {
        guard let spirits = currentSpirits else { return 0 }
        
        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }
    
    /// 특정 정령 타입 수량 증가
    func increaseSpirit(type: SpiritType, amount: Int = 1) async {
        guard let currentSpirits = currentSpirits else { return }
        
        do {
            self.currentSpirits = try await spiritsRepository.addSpirit(
                for: currentSpirits.playerId,
                spiritType: type,
                count: amount
            )
            print("🔥 Spirits: \(type.displayName) \(amount)개 증가 완료")
        } catch {
            self.error = error
            print("🔥 Spirits: \(type.displayName) 증가 실패 - \(error.localizedDescription)")
        }
    }
    
    /// 특정 정령 타입 수량 감소
    func decreaseSpirit(type: SpiritType, amount: Int = 1) async {
        guard let currentSpirits = currentSpirits else { return }
        
        do {
            // 감소를 위해 음수 값 사용
            self.currentSpirits = try await spiritsRepository.addSpirit(
                for: currentSpirits.playerId,
                spiritType: type,
                count: -amount
            )
            print("🔥 Spirits: \(type.displayName) \(amount)개 감소 완료")
        } catch {
            self.error = error
            print("🔥 Spirits: \(type.displayName) 감소 실패 - \(error.localizedDescription)")
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
    
    /// 정령 추가 (구매용)
    func addSpirit(_ spiritType: SpiritType, count: Int = 1) async {
        guard let currentSpirits = currentSpirits else {
            print("🔥 Spirits: 정령 추가 실패 - 데이터가 없습니다")
            return
        }
        
        do {
            let updatedSpirits = try await spiritsRepository.addSpirit(
                for: currentSpirits.playerId,
                spiritType: spiritType,
                count: count
            )
            self.currentSpirits = updatedSpirits
            print("🔥 Spirits: \(spiritType.displayName) \(count)마리 추가 완료")
        } catch {
            self.error = error
            print("🔥 Spirits: \(spiritType.displayName) 추가 실패 - \(error.localizedDescription)")
        }
    }
    
    /// 로그아웃 - 정령 데이터 초기화
    func logout() {
        currentSpirits = nil
        error = nil
        print("🔥 Spirits: 로그아웃 완료")
    }
}

