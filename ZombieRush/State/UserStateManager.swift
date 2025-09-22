//
//  UserStateManager.swift
//  ZombieRush
//
//  Created by User State Management with Supabase Integration
//

import Foundation
import Supabase
import SwiftUI

// MARK: - UserStateManager

@Observable
class UserStateManager {
    // MARK: - Properties
    var currentUser: User?
    var userImage: UIImage?  // Game Center 프로필 사진 (메모리에서만 관리)
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
            if let existingUser = try await fetchUser(by: playerID) {
                // 2. 닉네임 확인 및 업데이트
                currentUser = try await checkAndUpdateNicknameIfNeeded(existingUser, newNickname: nickname)
            } else {
                // 3. 사용자가 없으면 새로 생성
                let newUser = User(playerId: playerID, nickname: nickname)
                currentUser = try await createUser(newUser)
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
            let result = try await updateUserInDatabase(updatedUser)
            print("📱 UserState: 닉네임 업데이트 완료 - \(newNickname)")
            return result
        } else {
            print("📱 UserState: 기존 사용자 로드 성공 - \(existingUser.nickname)")
            return existingUser
        }
    }

    /// 사용자 데이터 업데이트
    func updateUser(_ updates: User) async {
        guard let user = currentUser else { return }

        do {
            currentUser = try await updateUserInDatabase(user)
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

        // 새로운 레벨 정보 계산
        let result = Level.addExperience(currentExp: currentUser.exp, expToAdd: exp)
        let newLevel = result.newLevel
        let leveledUp = result.leveledUp
        let levelsGained = result.levelsGained

        // 사용자 정보 업데이트
        var updatedUser = currentUser
        updatedUser.exp = newLevel.currentExp

        // 레벨업 시 remaining_points 3개씩 증가
        if leveledUp {
            updatedUser.remainingPoints += levelsGained * 3
        }

        // DB 업데이트
        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser

            if leveledUp {
                print("📱 UserState: 레벨 업! \(currentUser.level) → \(newLevel.currentLevel) (\(levelsGained)레벨 상승)")
                print("📱 UserState: 남은 포인트 증가: \(savedUser.remainingPoints)개")
            }
            print("📱 UserState: 경험치 추가 완료 - 총 EXP: \(newLevel.currentExp)")

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
        guard let currentUser = currentUser, currentUser.nemoFruit >= fruits else {
            print("📱 UserState: 네모열매가 부족합니다.")
            return false
        }

        var updatedUser = currentUser
        updatedUser.nemoFruit -= fruits

        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser
            print("📱 UserState: 네모열매 소비 완료 - 남은 네모열매: \(savedUser.nemoFruit)")
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

        // 이미 활성화된 응원이 있는지 확인
        if currentUser.isCheerBuffActive {
            print("📱 UserState: 네모의 응원이 이미 활성화되어 있습니다.")
            return false
        }

        // IAP 구현 전까지는 무조건 구매 가능 (테스트용)
        // TODO: IAP 구현 후 실제 결제 처리 및 네모열매 차감 제거

        // 3일 후 만료 시간 계산
        let expirationDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!

        var updatedUser = currentUser
        // IAP 구현 전까지는 네모열매 차감하지 않음
        // updatedUser.nemoFruit -= 3000
        updatedUser.cheerBuffExpiresAt = expirationDate

        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser
            print("📱 UserState: 네모의 응원 구매 완료 - 만료일: \(expirationDate)")
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

        var updatedUser = currentUser
        updatedUser.nemoFruit += fruits

        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser
            print("📱 UserState: 네모열매 추가 완료 - 총 네모열매: \(savedUser.nemoFruit)")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 네모열매 추가 실패 - \(error.localizedDescription)")
            return false
        }
    }

    /// 남은 포인트 소비
    func consumeRemainingPoints(_ points: Int) async -> Bool {
        guard let currentUser = currentUser, currentUser.remainingPoints >= points else {
            print("📱 UserState: 포인트가 부족합니다.")
            return false
        }

        var updatedUser = currentUser
        updatedUser.remainingPoints -= points

        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser
            print("📱 UserState: 포인트 소비 완료 - 남은 포인트: \(savedUser.remainingPoints)")
            return true
        } catch {
            self.error = error
            print("📱 UserState: 포인트 소비 실패 - \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Private Methods

    /// 사용자 조회
    private func fetchUser(by playerID: String) async throws -> User? {
        let users: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        return users.first
    }

    /// 사용자 생성
    private func createUser(_ user: User) async throws -> User {
        let createdUser: User = try await supabase
            .from("users")
            .insert(user)
            .select("*")
            .single()
            .execute()
            .value

        return createdUser
    }

    /// 사용자 업데이트
    private func updateUserInDatabase(_ user: User) async throws -> User {
        // 기본 필드들
        var updateData: [String: String] = [
            "nickname": user.nickname,
            "level": String(user.level),
            "exp": String(user.exp),
            "nemo_fruit": String(user.nemoFruit),
            "remaining_points": String(user.remainingPoints)
        ]

        // cheer_buff_expires_at이 있는 경우에만 추가 (nil이면 키 자체를 포함하지 않음)
        if let expiresAt = user.cheerBuffExpiresAt {
            updateData["cheer_buff_expires_at"] = expiresAt.ISO8601Format()
        }

        let updatedUser: User = try await supabase
            .from("users")
            .update(updateData)
            .eq("player_id", value: user.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedUser
    }
}
