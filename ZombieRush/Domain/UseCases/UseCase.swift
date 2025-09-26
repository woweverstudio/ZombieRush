//
//  UseCase.swift
//  ZombieRush
//
//  Created by UseCase Protocol Definition
//

/// UseCase 프로토콜 - 모든 UseCase의 기본 인터페이스
/// View → UseCase → Repository → Model 아키텍처에서 UseCase 계층의 표준
protocol UseCase {
    associatedtype Request
    associatedtype Response
    func execute(_ request: Request) async throws -> Response
}
