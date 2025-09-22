//
//  UserStateManager.swift
//  ZombieRush
//
//  Created by User State Management with Supabase Integration
//

import Foundation
import SwiftUI

// MARK: - UserStateManager

@Observable
class UserStateManager {
    // MARK: - Properties
    var currentUser: User?
    var userImage: UIImage?  // Game Center 프로필 사진 (메모리에서만 관리)
    var isLoading = false
    var error: Error?

    // Repository
    private let userRepository: UserRepository

    init(userRepository: UserRepository = SupabaseUserRepository()) {
        self.userRepository = userRepository
    }

    // Legacy init for backward compatibility
    convenience init() {
        self.init(userRepository: SupabaseUserRepository())
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

}
