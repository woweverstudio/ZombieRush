//
//  JobsStateManager.swift
//  ZombieRush
//
//  Created by Jobs State Management with Supabase Integration
//

import Foundation
import SwiftUI

@Observable
class JobsStateManager {
    // MARK: - Properties
    var currentJobs: Jobs = .defaultJobs(for: "")
    var isLoading = false
    var error: Error?

    // Repository
    private let jobsRepository: JobsRepository

    // MARK: - UI State Properties
    var currentTab = 0  // 현재 보고 있는 탭 인덱스

    init(jobsRepository: JobsRepository = SupabaseJobsRepository()) {
        self.jobsRepository = jobsRepository
    }

    // Legacy init for backward compatibility
    convenience init() {
        self.init(jobsRepository: SupabaseJobsRepository())
    }

    // MARK: - Computed Properties

    /// 현재 선택된 직업 (DB에서 불러온 값)
    var selectedJob: String {
        return currentJobs.selectedJob
    }

    /// 현재 선택된 직업 타입 (DB에서 불러온 값)
    var selectedJobType: JobType {
        return currentJobs.selectedJobType
    }

    /// 현재 선택된 직업의 표시 이름
    var currentJobName: String {
        selectedJobType.displayName
    }

    /// 현재 보고 있는 job의 스탯 (TabView에서 현재 표시되는 job 기준)
    var currentJobStats: JobStats {
        return JobStats.getStats(for: selectedJobType.rawValue)
    }

    /// 현재 직업의 체력 (기본값: 100)
    var hp: Int {
        currentJobStats.hp
    }

    /// 현재 직업의 에너지 (기본값: 50)
    var energy: Int {
        currentJobStats.energy
    }

    /// 현재 직업의 이동속도 (기본값: 10)
    var move: Int {
        currentJobStats.move
    }

    /// 현재 직업의 공격속도 (기본값: 10)
    var attackSpeed: Int {
        currentJobStats.attackSpeed
    }


    // MARK: - Public Methods

    /// 플레이어 ID로 직업 데이터 로드 또는 생성
    func loadOrCreateJobs(playerID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 직업 조회 시도
            if let existingJobs = try await jobsRepository.getJobs(by: playerID) {
                currentJobs = existingJobs
                print("⚔️ Jobs: 기존 직업 로드 성공 - 선택: \(existingJobs.selectedJob)")
            } else {
                // 2. 직업이 없으면 새로 생성
                let newJobs = Jobs.defaultJobs(for: playerID)
                currentJobs = try await jobsRepository.createJobs(newJobs)
                print("⚔️ Jobs: 새 직업 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 직업 데이터 업데이트
    func updateJobs(_ updates: Jobs) async {
        do {
            currentJobs = try await jobsRepository.updateJobs(updates)
            print("⚔️ Jobs: 직업 업데이트 성공")
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 업데이트 실패 - \(error.localizedDescription)")
        }
    }

    /// 직업 잠금 해제
    func unlockJob(_ jobType: JobType) async {
        do {
            currentJobs = try await jobsRepository.unlockJob(for: currentJobs.playerId, jobType: jobType)
            print("⚔️ Jobs: \(jobType.displayName) 잠금 해제 성공")
        } catch {
            self.error = error
            print("⚔️ Jobs: \(jobType.displayName) 잠금 해제 실패 - \(error.localizedDescription)")
        }
    }

    /// 직업 선택
    func selectJob(_ jobType: JobType) async {
        do {
            currentJobs = try await jobsRepository.selectJob(for: currentJobs.playerId, jobType: jobType)
            print("⚔️ Jobs: 직업 선택 완료 - \(jobType.displayName)")
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 선택 실패 - \(error.localizedDescription)")
        }
    }

    /// 모든 직업 잠금 해제 (치트/테스트용)
    func unlockAllJobs() async {
        currentJobs.novice = true
        currentJobs.fireMage = true
        currentJobs.iceMage = true
        currentJobs.lightningMage = true
        currentJobs.darkMage = true

        await updateJobs(currentJobs)
        print("⚔️ Jobs: 모든 직업 잠금 해제됨")
    }

    /// 직업 초기화
    func resetJobs() {
        currentJobs.novice = true
        currentJobs.fireMage = false
        currentJobs.iceMage = false
        currentJobs.lightningMage = false
        currentJobs.darkMage = false
        currentJobs.selectedJob = "novice"

        Task {
            await updateJobs(currentJobs)
        }
    }

    /// 현재 직업 정보 출력 (테스트용)
    func printCurrentJobs() {
        let jobs = currentJobs
        print("⚔️ Jobs: === 현재 직업 정보 ===")
        print("⚔️ PlayerID: \(jobs.playerId)")
        print("⚔️ 초보자: \(jobs.novice ? "✅" : "❌")")
        print("⚔️ 불 마법사: \(jobs.fireMage ? "✅" : "❌")")
        print("⚔️ 얼음 마법사: \(jobs.iceMage ? "✅" : "❌")")
        print("⚔️ 번개 마법사: \(jobs.lightningMage ? "✅" : "❌")")
        print("⚔️ 어둠 마법사: \(jobs.darkMage ? "✅" : "❌")")
        print("⚔️ 선택된 직업: \(jobs.selectedJobType.displayName)")
        print("⚔️ 잠금 해제된 직업 수: \(jobs.unlockedJobs.count)")
        print("⚔️ =================================")


        if let error = error {
            print("⚔️ Jobs: 마지막 에러 - \(error.localizedDescription)")
        }
    }

}
