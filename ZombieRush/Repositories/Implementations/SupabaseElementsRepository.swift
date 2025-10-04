//
//  SupabaseElementsRepository.swift
//  ZombieRush
//
//  Created by Supabase Implementation of ElementsRepository
//

import Foundation
import Supabase
import SwiftUI

/// Supabase를 사용한 ElementsRepository 구현체
@MainActor
final class SupabaseElementsRepository: ObservableObject, ElementsRepository {
    // Observable properties for View observation
    @Published var currentElements: Elements?

    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }

    func getElements(by playerID: String) async throws -> Elements? {
        let elements: [Elements] = try await supabase
            .from("elements")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        let element = elements.first
        currentElements = element
        return element
    }

    func createElements(_ elements: Elements) async throws -> Elements {
        let createdElements: Elements = try await supabase
            .from("elements")
            .insert(elements)
            .select("*")
            .single()
            .execute()
            .value

        currentElements = createdElements
        return createdElements
    }

    func updateElements(_ elements: Elements) async throws -> Elements {
        let updatedElements: Elements = try await supabase
            .from("elements")
            .update([
                "fire": String(elements.fire),
                "ice": String(elements.ice),
                "thunder": String(elements.thunder),
                "dark": String(elements.dark)
            ])
            .eq("player_id", value: elements.playerId)
            .select("*")
            .single()
            .execute()
            .value

        currentElements = updatedElements
        return updatedElements
    }

    /// 네모열매를 소비하여 원소 교환 (트랜잭션)
    func exchangeFruitForElement(playerID: String, elementType: String, amount: Int) async throws -> (Elements, User) {
        // RPC 호출 및 JSON 파싱
        let data = try await supabase
            .rpc("exchange_fruit_for_element", params: [
                "p_player_id": playerID,
                "p_element_type": elementType,
                "p_amount": String(amount)
            ])
            .execute()
            .data

        // RPCDecoder로 간단하게 파싱
        let response = try RPCDecoder.decode(TransactionResponse.self, from: data)

        // Repository 상태 업데이트
        currentElements = response.elements

        return (response.elements, response.user)
    }

    // 트랜잭션 응답 구조체
    private struct TransactionResponse: Codable {
        let user: User
        let elements: Elements
    }

}
