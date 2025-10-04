//
//  JobsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Jobs Data Access
//

import Foundation

/// 직업 데이터 액세스를 위한 Repository Protocol
@MainActor
protocol JobsRepository: AnyObject {
    /// 직업 상태
    var currentJobs: Jobs? { get set }
    
    /// 직업 데이터 조회
    func getJobs(by playerID: String) async throws -> Jobs?

    /// 직업 데이터 생성
    func createJobs(_ jobs: Jobs) async throws -> Jobs

    /// 직업 데이터 업데이트
    func updateJobs(_ jobs: Jobs) async throws -> Jobs

    /// 직업 해금 (정령 차감 포함 트랜잭션)
    func unlockJobWithTransaction(playerID: String, jobKey: String) async throws -> (jobs: Jobs, elements: Elements)

}
