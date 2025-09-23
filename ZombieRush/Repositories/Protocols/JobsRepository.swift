//
//  JobsRepository.swift
//  ZombieRush
//
//  Created by Repository Pattern for Jobs Data Access
//

import Foundation

/// 데이터 변경 콜백 타입
typealias JobsDataChangeCallback = () async -> Void

/// 직업 데이터 액세스를 위한 Repository Protocol
protocol JobsRepository: AnyObject {
    /// 데이터 변경 시 호출될 콜백
    var onDataChanged: JobsDataChangeCallback? { get set }
    /// 직업 데이터 조회
    func getJobs(by playerID: String) async throws -> Jobs?

    /// 직업 데이터 생성
    func createJobs(_ jobs: Jobs) async throws -> Jobs

    /// 직업 데이터 업데이트
    func updateJobs(_ jobs: Jobs) async throws -> Jobs

    /// 직업 선택
    func selectJob(for playerID: String, jobType: JobType) async throws -> Jobs

    /// 직업 해금
    func unlockJob(for playerID: String, jobType: JobType) async throws -> Jobs
}
