//
//  SupabaseUserRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of UserRepository
//

import Foundation
import Supabase
import SwiftUI

/// Supabase를 사용한 UserRepository 구현체
final class SupabaseUserRepository: ObservableObject, UserRepository {
    // Observable properties for View observation
    @Published var currentUser: User?

    private let supabase: SupabaseClient

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

        let user = users.first
        currentUser = user
        return user
    }

    func createUser(_ user: User) async throws -> User {
        let createdUser: User = try await supabase
            .from("users")
            .insert(user)
            .select("*")
            .single()
            .execute()
            .value

        currentUser = createdUser
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

        do {
            let updatedUser: User = try await supabase
                .from("users")
                .update(updateData)
                .eq("player_id", value: user.playerId)
                .select("*")
                .single()
                .execute()
                .value

            currentUser = updatedUser
            return updatedUser
        } catch {
            // ✅ 네트워크/DB 실패 시 네트워크 에러 표시
            GlobalErrorManager.shared.showError(.network(.serverError(code: 500)))
            throw error
        }
    }

}
