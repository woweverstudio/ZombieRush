//
//  JobsStateManager.swift
//  ZombieRush
//
//  Created by Jobs State Management with Supabase Integration
//

import Foundation
import Supabase
import SwiftUI

@Observable
class JobsStateManager {
    // MARK: - Properties
    var currentJobs: Jobs?
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

    // MARK: - Public Methods

    /// 플레이어 ID로 직업 데이터 로드 또는 생성
    func loadOrCreateJobs(playerID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 직업 조회 시도
            if let existingJobs = try await fetchJobs(by: playerID) {
                currentJobs = existingJobs
                print("⚔️ Jobs: 기존 직업 로드 성공 - 선택: \(existingJobs.selectedJob)")
            } else {
                // 2. 직업이 없으면 새로 생성
                let newJobs = Jobs.defaultJobs(for: playerID)
                currentJobs = try await createJobs(newJobs)
                print("⚔️ Jobs: 새 직업 생성 성공 - 기본값으로 초기화")
            }
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 로드/생성 실패 - \(error.localizedDescription)")
        }
    }

    /// 직업 데이터 업데이트
    func updateJobs(_ updates: Jobs) async {
        guard let jobs = currentJobs else { return }

        do {
            currentJobs = try await updateJobsInDatabase(jobs)
            print("⚔️ Jobs: 직업 업데이트 성공")
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 업데이트 실패 - \(error.localizedDescription)")
        }
    }

    /// 직업 잠금 해제
    func unlockJob(_ jobType: JobType) async {
        guard var jobs = currentJobs else { return }

        switch jobType {
        case .novice:
            jobs.novice = true
        case .fireMage:
            jobs.fireMage = true
        case .iceMage:
            jobs.iceMage = true
        case .lightningMage:
            jobs.lightningMage = true
        case .darkMage:
            jobs.darkMage = true
        }

        await updateJobs(jobs)
    }

    /// 직업 선택
    func selectJob(_ jobType: JobType) async {
        guard var jobs = currentJobs else { return }

        // 선택하려는 직업이 잠금 해제되었는지 확인
        switch jobType {
        case .novice:
            guard jobs.novice else { return }
        case .fireMage:
            guard jobs.fireMage else { return }
        case .iceMage:
            guard jobs.iceMage else { return }
        case .lightningMage:
            guard jobs.lightningMage else { return }
        case .darkMage:
            guard jobs.darkMage else { return }
        }

        jobs.selectedJob = jobType.rawValue
        await updateJobs(jobs)
        print("⚔️ Jobs: 직업 선택 완료 - \(jobType.displayName)")
    }

    /// 모든 직업 잠금 해제 (치트/테스트용)
    func unlockAllJobs() async {
        guard var jobs = currentJobs else { return }

        jobs.novice = true
        jobs.fireMage = true
        jobs.iceMage = true
        jobs.lightningMage = true
        jobs.darkMage = true

        await updateJobs(jobs)
        print("⚔️ Jobs: 모든 직업 잠금 해제됨")
    }

    /// 직업 초기화
    func resetJobs() {
        guard var jobs = currentJobs else { return }
        jobs.novice = true
        jobs.fireMage = false
        jobs.iceMage = false
        jobs.lightningMage = false
        jobs.darkMage = false
        jobs.selectedJob = "novice"

        Task {
            await updateJobs(jobs)
        }
    }

    /// 현재 직업 정보 출력 (테스트용)
    func printCurrentJobs() {
        if let jobs = currentJobs {
            print("⚔️ Jobs: === 현재 직업 정보 ===")
            print("⚔️ PlayerID: \(jobs.playerId)")
            print("⚔️ 초보자: \(jobs.novice ? "✅" : "❌")")
            print("⚔️ 불 마법사: \(jobs.fireMage ? "✅" : "❌")")
            print("⚔️ 얼음 마법사: \(jobs.iceMage ? "✅" : "❌")")
            print("⚔️ 번개 마법사: \(jobs.lightningMage ? "✅" : "❌")")
            print("⚔️ 어둠 마법사: \(jobs.darkMage ? "✅" : "❌")")
            print("⚔️ 선택된 직업: \(jobs.selectedJobType?.displayName ?? "알 수 없음")")
            print("⚔️ 잠금 해제된 직업 수: \(jobs.unlockedJobs.count)")
            print("⚔️ =================================")
        } else {
            print("⚔️ Jobs: 현재 직업 정보가 없습니다.")
        }

        if let error = error {
            print("⚔️ Jobs: 마지막 에러 - \(error.localizedDescription)")
        }
    }

    /// 로그아웃 - 직업 데이터 초기화
    func logout() {
        currentJobs = nil
        error = nil
        print("⚔️ Jobs: 로그아웃 완료")
    }

    // MARK: - Computed Properties for UI

    /// 현재 선택된 직업의 스탯 정보
    var currentJobStats: JobStats? {
        guard let selectedJob = currentJobs?.selectedJob else {
            return nil
        }
        return JobStats.getStats(for: selectedJob)
    }

    /// 현재 선택된 직업의 표시 이름
    var currentJobName: String {
        currentJobs?.selectedJobType?.displayName ?? "초보자"
    }

    /// 현재 선택된 직업 타입
    var currentJobType: JobType? {
        currentJobs?.selectedJobType
    }

    // MARK: - Individual Stat Properties (No Optional Chaining in Views)

    /// 현재 직업의 체력 (기본값: 100)
    var hp: Int {
        currentJobStats?.hp ?? 100
    }

    /// 현재 직업의 에너지 (기본값: 50)
    var energy: Int {
        currentJobStats?.energy ?? 50
    }

    /// 현재 직업의 이동속도 (기본값: 10)
    var move: Int {
        currentJobStats?.move ?? 10
    }

    /// 현재 직업의 공격속도 (기본값: 10)
    var attackSpeed: Int {
        currentJobStats?.attackSpeed ?? 10
    }

    // MARK: - Private Methods

    /// 직업 조회
    private func fetchJobs(by playerID: String) async throws -> Jobs? {
        let jobs: [Jobs] = try await supabase
            .from("jobs")
            .select("*")
            .eq("player_id", value: playerID)
            .execute()
            .value

        return jobs.first
    }

    /// 직업 생성
    private func createJobs(_ jobs: Jobs) async throws -> Jobs {
        let createdJobs: Jobs = try await supabase
            .from("jobs")
            .insert(jobs)
            .select("*")
            .single()
            .execute()
            .value

        return createdJobs
    }

    /// 직업 업데이트
    private func updateJobsInDatabase(_ jobs: Jobs) async throws -> Jobs {
        let updatedJobs: Jobs = try await supabase
            .from("jobs")
            .update([
                "novice": jobs.novice ? "true" : "false",
                "fire_mage": jobs.fireMage ? "true" : "false",
                "ice_mage": jobs.iceMage ? "true" : "false",
                "lightning_mage": jobs.lightningMage ? "true" : "false",
                "dark_mage": jobs.darkMage ? "true" : "false",
                "selected_job": jobs.selectedJob
            ])
            .eq("player_id", value: jobs.playerId)
            .select("*")
            .single()
            .execute()
            .value

        return updatedJobs
    }
}
