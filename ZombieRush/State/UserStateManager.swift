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

    // MARK: - Level Management

    /// 현재 레벨 정보 (경험치로부터 계산된 값)
    var currentLevel: Level? {
        guard let user = currentUser else { return nil }
        return Level(currentExp: user.exp)
    }

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
    
    var level: Int {
        currentUser?.level ?? 1
    }
    
    var experience: Int {
        currentUser?.exp ?? 0
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
            print("📱 Cheer Buff: \(user.cheerBuff)")
            print("📱 Profile Photo: \(userImage != nil ? "✅" : "❌")")
            print("📱 Created At: \(user.createdAt)")
            print("📱 Updated At: \(user.updatedAt)")
            print("📱 =================================")

            // 레벨 정보도 출력
            if let level = currentLevel {
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
        // level은 exp로부터 자동 계산됨

        // DB 업데이트
        do {
            let savedUser = try await updateUserInDatabase(updatedUser)
            self.currentUser = savedUser

            if leveledUp {
                print("📱 UserState: 레벨 업! \(currentUser.level) → \(newLevel.currentLevel) (\(levelsGained)레벨 상승)")
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
        return currentLevel?.progress ?? 0.0
    }

    /// 다음 레벨까지 남은 경험치
    var expToNextLevel: Int {
        return currentLevel?.remainingExp ?? 0
    }

    /// 레벨 업 가능 여부 확인
    func canLevelUp(withAdditionalExp exp: Int) -> Bool {
        guard let currentLevel = currentLevel else { return false }
        let result = currentLevel.addExperience(exp)
        return result.leveledUp
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
        let updatedUser: User = try await supabase
            .from("users")
            .update([
                "nickname": user.nickname,
                "level": String(user.level),
                "exp": String(user.exp),
                "nemo_fruit": String(user.nemoFruit),
                "cheer_buff": user.cheerBuff ? "true" : "false"
            ])
            .eq("player_id", value: user.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedUser
    }
}
