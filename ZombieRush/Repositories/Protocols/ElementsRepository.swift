//
//  ElementsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Elements Data Access
//

import Foundation

/// 원소 데이터 액세스를 위한 Repository Protocol
@MainActor
protocol ElementsRepository: AnyObject {
    /// 원소 상태
    var currentElements: Elements? { get set }

    /// 원소 데이터 조회
    func getElements(by playerID: String) async throws -> Elements?

    /// 원소 데이터 생성
    func createElements(_ elements: Elements) async throws -> Elements

    /// 원소 데이터 업데이트
    func updateElements(_ elements: Elements) async throws -> Elements

    /// 젬을 소비하여 원소 교환 (트랜잭션)
    func exchangeGemForElement(playerID: String, elementType: String, amount: Int) async throws -> (Elements, User)
}
