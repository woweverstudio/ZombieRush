//
//  UserStateManager.swift
//  ZombieRush
//
//  Created by User State Management with Supabase Integration
//

import Foundation
import SwiftUI

/// 사용자 데이터와 상태를 관리하는 StateManager
/// View와 Repository 사이의 중간 계층으로 비즈니스 로직을 처리
@Observable
class UserStateManager {
    // MARK: - Internal Properties (View에서 접근 가능)
    var currentUser: User?
    var userImage: UIImage?  // Game Center 프로필 사진 (메모리에서만 관리)
    var isLoading = false
    var error: Error?

    // MARK: - Private Properties (내부 전용)
    private let userRepository: UserRepository
    private let spiritsRepository: SpiritsRepository

    init(userRepository: UserRepository,
         spiritsRepository: SpiritsRepository) {
        self.userRepository = userRepository
        self.spiritsRepository = spiritsRepository
    }
    
    var nickname: String {
        currentUser?.nickname ?? ""
    }
    
    /// 현재 레벨 정보 (경험치로부터 계산된 값)
    var level: Level? {
        guard let user = currentUser else { return nil }
        return Level(currentExp: user.exp)
    }
    
    var experience: Int {
        currentUser?.exp ?? 0
    }

    var remainingPoints: Int {
        currentUser?.remainingPoints ?? 0
    }

    var nemoFruits: Int {
        currentUser?.nemoFruit ?? 0
    }
    
    var isCheerBuffActive: Bool {
        currentUser?.isCheerBuffActive ?? false
    }

    // MARK: - Public Methods

    /// Game Center playerID를 사용해 사용자 데이터 로드 또는 생성
    func loadOrCreateUser(playerID: String, nickname: String, photo: UIImage? = nil) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 프로필 사진 저장 (항상 최신 사진으로 업데이트)
            userImage = photo

            // 1. 사용자 조회 시도
            if let existingUser = try await userRepository.getUser(by: playerID) {
                // 2. 닉네임 확인 및 업데이트
                currentUser = try await checkAndUpdateNicknameIfNeeded(existingUser, newNickname: nickname)
            } else {
                // 3. 사용자가 없으면 새로 생성
                let newUser = User(playerId: playerID, nickname: nickname)
                currentUser = try await userRepository.createUser(newUser)
                print("📱 UserState: 새 사용자 생성 성공 - \(newUser.nickname)")
            }
        } catch {
            self.error = error
            print("📱 UserState: 사용자 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 닉네임 변경 확인 및 업데이트
    private func checkAndUpdateNicknameIfNeeded(_ existingUser: User, newNickname: String) async throws -> User {
        // 닉네임이 변경되었는지 확인
        if existingUser.nickname != newNickname {
            print("📱 UserState: 닉네임 변경 감지 - 기존: '\(existingUser.nickname)' → 새로고침: '\(newNickname)'")
            var updatedUser = existingUser
            updatedUser.nickname = newNickname
            let result = try await userRepository.updateUser(updatedUser)
            print("📱 UserState: 닉네임 업데이트 완료 - \(newNickname)")
            return result
        } else {
            print("📱 UserState: 기존 사용자 로드 성공 - \(existingUser.nickname)")
            return existingUser
        }
    }

    /// 사용자 데이터 업데이트
    func updateUser(_ updates: User) async {
        do {
            currentUser = try await userRepository.updateUser(updates)
            print("📱 UserState: 사용자 업데이트 성공")
        } catch {
            self.error = error
            print("📱 UserState: 사용자 업데이트 실패 - \(error.localizedDescription)")
        }
    }

    /// 현재 사용자 정보 출력 (테스트용)
    func printCurrentUser() {
        if let user = currentUser {
            print("📱 UserState: === 현재 사용자 정보 ===")
            print("📱 PlayerID: \(user.playerId)")
            print("📱 Nickname: \(user.nickname)")
            print("📱 Level: \(user.level)")
            print("📱 EXP: \(user.exp)")
            print("📱 Nemo Fruit: \(user.nemoFruit)")
            print("📱 Remaining Points: \(user.remainingPoints)")
            print("📱 Cheer Buff: \(user.cheerBuffExpiresAt ?? .distantPast)")
            print("📱 Profile Photo: \(userImage != nil ? "✅" : "❌")")
            print("📱 Created At: \(user.createdAt)")
            print("📱 Updated At: \(user.updatedAt)")
            print("📱 =================================")

            // 레벨 정보도 출력
            if let level {
                print("📱 Level Info: \(level.levelInfo)")
                print("📱 Progress: \(level.progressPercentage)")
                print("📱 To Next Level: \(level.remainingExp) EXP")
            }
        } else {
            print("📱 UserState: 현재 사용자 정보가 없습니다.")
        }

        if let error = error {
            print("📱 UserState: 마지막 에러 - \(error.localizedDescription)")
        }
    }

    // MARK: - Experience & Level Management

    /// 경험치 추가 (레벨 업 자동 처리)
    func addExperience(_ exp: Int) async -> (leveledUp: Bool, levelsGained: Int) {
        guard let currentUser = currentUser else {
            print("📱 UserState: 사용자 정보가 없어 경험치를 추가할 수 없습니다.")
            return (false, 0)
        }

        do {
            let updatedUser = try await userRepository.addExperience(to: currentUser.playerId, exp: exp)
            self.currentUser = updatedUser

            // 레벨 계산 결과
            let oldLevel = Level(currentExp: currentUser.exp)
            let newLevel = Level(currentExp: updatedUser.exp)
            let leveledUp = newLevel.currentLevel > oldLevel.currentLevel
            let levelsGained = newLevel.currentLevel - oldLevel.currentLevel

            if leveledUp {
                print("📱 UserState: 레벨 업! \(oldLevel.currentLevel) → \(newLevel.currentLevel) (\(levelsGained)레벨 상승)")
                print("📱 UserState: 남은 포인트 증가: \(updatedUser.remainingPoints)개")
            }
            print("📱 UserState: 경험치 추가 완료 - 총 EXP: \(updatedUser.exp)")

            return (leveledUp, levelsGained)
        } catch {
            self.error = error
            print("📱 UserState: 경험치 추가 실패 - \(error.localizedDescription)")
            return (false, 0)
        }
    }

    /// 현재 레벨 진행률 (0.0 ~ 1.0)
    var levelProgress: Double {
        return level?.progress ?? 0.0
    }

    /// 다음 레벨까지 남은 경험치
    var expToNextLevel: Int {
        return level?.remainingExp ?? 0
    }

    /// 레벨 업 가능 여부 확인
    func canLevelUp(withAdditionalExp exp: Int) -> Bool {
        guard let currentLevel = level else { return false }
        let result = currentLevel.addExperience(exp)
        return result.leveledUp
    }

    /// 네모열매 소비
    func consumeNemoFruits(_ fruits: Int) async -> Bool {
        guard let currentUser = currentUser else {
            print("📱 UserState: 사용자 정보가 없습니다.")
            return false
        }

        do {
            let updatedUser = try await userRepository.addNemoFruits(to: currentUser.playerId, count: -fruits)
            self.currentUser = updatedUser
            print("📱 UserState: 네모열매 소비 완료 - 남은 네모열매: \(updatedUser.nemoFruit)")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 네모열매 소비 실패 - \(error.localizedDescription)")
            return false
        }
    }

    /// 네모의 응원 구매 (3000원, 3일) - IAP 구현 전까지 테스트용
    func purchaseCheerBuff() async -> Bool {
        guard let currentUser = currentUser else {
            print("📱 UserState: 사용자가 없습니다.")
            return false
        }

        do {
            let updatedUser = try await userRepository.purchaseCheerBuff(for: currentUser.playerId, duration: 3 * 24 * 60 * 60) // 3일
            self.currentUser = updatedUser
            print("📱 UserState: 네모의 응원 구매 완료 - 만료일: \(updatedUser.cheerBuffExpiresAt ?? Date())")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 네모의 응원 구매 실패 - \(error.localizedDescription)")
            return false
        }
    }

    /// 네모열매 추가
    func addNemoFruits(_ fruits: Int) async -> Bool {
        guard let currentUser = currentUser else {
            print("📱 UserState: 사용자 정보가 없어 네모열매를 추가할 수 없습니다.")
            return false
        }

        do {
            let updatedUser = try await userRepository.addNemoFruits(to: currentUser.playerId, count: fruits)
            self.currentUser = updatedUser
            print("📱 UserState: 네모열매 추가 완료 - 총 네모열매: \(updatedUser.nemoFruit)")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 네모열매 추가 실패 - \(error.localizedDescription)")
            return false
        }
    }

    /// 남은 포인트 소비
    func consumeRemainingPoints(_ points: Int) async -> Bool {
        guard let currentUser = currentUser else {
            print("📱 UserState: 사용자 정보가 없습니다.")
            return false
        }

        do {
            let updatedUser = try await userRepository.consumePoints(of: currentUser.playerId, points: points)
            self.currentUser = updatedUser
            print("📱 UserState: 포인트 소비 완료 - 남은 포인트: \(updatedUser.remainingPoints)")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 포인트 소비 실패 - \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Market Related Methods (마켓 구매 기능)

    /// 마켓 아이템 구매 가능 여부 확인
    func canAffordMarketItem(_ item: MarketItem) -> Bool {
        switch item.currencyType {
        case .won:
            // IAP 구현 전까지는 무조건 구매 가능 (테스트용)
            return true
        case .fruit:
            return nemoFruits >= item.price
        }
    }

    /// 마켓 아이템 구매 처리
    func purchaseMarketItem(_ item: MarketItem) async -> Bool {
        guard canAffordMarketItem(item) else {
            print("📱 UserState: 마켓 아이템 구매 실패 - 재화 부족")
            return false
        }

        switch item.type {
        case .fruitPackage(count: let count, price: _):
            // 네모열매 패키지 구매
            print("📱 UserState: 네모열매 \(count)개 패키지 구매 (₩\(item.price))")
            return await addNemoFruits(count)

        case .cheerBuff(days: let days, price: _):
            // 네모의 응원 구매
            print("📱 UserState: 네모의 응원 \(days)일 구매 (₩\(item.price))")
            return await purchaseCheerBuff()
        }
    }

    /// 마켓 아이템 목록 (기본 아이템들)
    var marketItems: [MarketItem] {
        [
            // 네모열매 패키지
            MarketItem(
                type: .fruitPackage(count: 20, price: 2000),
                name: "네모열매 20개",
                description: "네모열매 20개를 즉시 충전",
                iconName: "diamond.fill",
                price: 2000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 55, price: 5000),
                name: "네모열매 55개",
                description: "네모열매 55개를 즉시 충전 (약 15% 보너스)",
                iconName: "diamond.fill",
                price: 5000,
                currencyType: .won
            ),
            MarketItem(
                type: .fruitPackage(count: 110, price: 10000),
                name: "네모열매 110개",
                description: "네모열매 110개를 즉시 충전 (약 10% 보너스)",
                iconName: "diamond.fill",
                price: 10000,
                currencyType: .won
            ),
            // 네모의 응원
            MarketItem(
                type: .cheerBuff(days: 3, price: 3000),
                name: "네모의 응원",
                description: "3일간 네모의 응원을 받습니다",
                iconName: "star.circle.fill",
                price: 3000,
                currencyType: .won
            )
        ]
    }

// MARK: - Spirit Purchase Methods (정령 구매 기능)

    /// 정령 구매 가능 여부 확인
    func canAffordSpiritPurchase(quantity: Int) -> Bool {
        return nemoFruits >= quantity
    }

    /// 정령 구매 처리
    func purchaseSpirits(_ spiritType: SpiritType, quantity: Int) async -> Bool {
        guard canAffordSpiritPurchase(quantity: quantity) else {
            print("📱 UserState: 정령 구매 실패 - 네모열매 부족")
            return false
        }

        guard let currentUser = currentUser else {
            print("📱 UserState: 정령 구매 실패 - 사용자 정보 없음")
            return false
        }

        do {
            // 네모열매 차감
            let consumeSuccess = await consumeNemoFruits(quantity)
            if !consumeSuccess {
                print("📱 UserState: 정령 구매 실패 - 네모열매 차감 실패")
                return false
            }

            // 정령 추가 (SpiritsRepository 직접 사용)
            _ = try await spiritsRepository.addSpirit(
                for: currentUser.playerId,
                spiritType: spiritType,
                count: quantity
            )

            print("🔥 UserState: \(spiritType.displayName) \(quantity)마리 구매 완료")
            return true

        } catch {
            self.error = error
            print("📱 UserState: 정령 구매 실패 - \(error.localizedDescription)")
            return false
        }
    }
}


// MARK: - Market Item Types (마켓 관련 타입들)

/// 마켓 아이템 타입
enum MarketItemType {
    case fruitPackage(count: Int, price: Int)
    case cheerBuff(days: Int, price: Int)
}

/// 마켓 아이템
struct MarketItem: Identifiable {
    let id = UUID()
    let type: MarketItemType
    let name: String
    let description: String
    let iconName: String
    let price: Int
    let currencyType: CurrencyType

    enum CurrencyType {
        case won
        case fruit
    }
}
