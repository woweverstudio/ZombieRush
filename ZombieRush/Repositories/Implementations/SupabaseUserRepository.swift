//
//  SupabaseUserRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of UserRepository
//

import Foundation
import Supabase

/// Supabase를 사용한 UserRepository 구현체
class SupabaseUserRepository: UserRepository {
    private let supabase: SupabaseClient

    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: UserDataChangeCallback?

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    func getUser(by playerID: String) async throws -> User? {
        let users: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        return users.first
    }

    func createUser(_ user: User) async throws -> User {
        let createdUser: User = try await supabase
            .from("users")
            .insert(user)
            .select("*")
            .single()
            .execute()
            .value

        return createdUser
    }

    func updateUser(_ user: User) async throws -> User {
        // 기본 필드들
        var updateData: [String: String] = [
            "nickname": user.nickname,
            "level": String(user.level),
            "exp": String(user.exp),
            "nemo_fruit": String(user.nemoFruit),
            "remaining_points": String(user.remainingPoints)
        ]

        // cheer_buff_expires_at이 있는 경우에만 추가
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

        // 데이터 변경 콜백 호출
        await onDataChanged?()

        return updatedUser
    }

    func addExperience(to playerID: String, exp: Int) async throws -> User {
        // 1. 현재 사용자 정보 조회
        guard let currentUser = try await getUser(by: playerID) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        // 2. 경험치 추가 및 레벨 계산
        let result = Level.addExperience(currentExp: currentUser.exp, expToAdd: exp)
        let newLevel = result.newLevel
        let leveledUp = result.leveledUp
        let levelsGained = result.levelsGained

        // 3. 사용자 정보 업데이트
        var updatedUser = currentUser
        updatedUser.exp = newLevel.currentExp

        // 레벨업 시 remaining_points 증가
        if leveledUp {
            updatedUser.remainingPoints += levelsGained * 3
        }

        // 4. DB 업데이트
        return try await updateUser(updatedUser)
    }

    func addNemoFruits(to playerID: String, count: Int) async throws -> User {
        guard let currentUser = try await getUser(by: playerID) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        var updatedUser = currentUser
        updatedUser.nemoFruit += count

        return try await updateUser(updatedUser)
    }

    func consumePoints(of playerID: String, points: Int) async throws -> User {
        guard let currentUser = try await getUser(by: playerID) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        guard currentUser.remainingPoints >= points else {
            throw NSError(domain: "UserRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient points"])
        }

        var updatedUser = currentUser
        updatedUser.remainingPoints -= points

        return try await updateUser(updatedUser)
    }

    func purchaseCheerBuff(for playerID: String, duration: TimeInterval) async throws -> User {
        guard let currentUser = try await getUser(by: playerID) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        // 이미 활성화된 응원이 있는지 확인
        if currentUser.isCheerBuffActive {
            throw NSError(domain: "UserRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cheer buff already active"])
        }

        // IAP 구현 전까지는 네모열매 차감하지 않음
        let expirationDate = Date().addingTimeInterval(duration)

        var updatedUser = currentUser
        // IAP 구현 전까지는 네모열매 차감하지 않음
        // updatedUser.nemoFruit -= 3000
        updatedUser.cheerBuffExpiresAt = expirationDate

        return try await updateUser(updatedUser)
    }
}
