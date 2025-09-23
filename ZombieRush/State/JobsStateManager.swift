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
    // MARK: - Internal Properties (View에서 접근 가능)
    var currentJobs: Jobs = .defaultJobs(for: "")
    var isLoading = false
    var error: Error?

    // MARK: - UI State Properties (View 전용)
    var currentTab = 0  // 현재 보고 있는 탭 인덱스

    // MARK: - Private Properties (내부 전용)
    private let jobsRepository: JobsRepository
    private let spiritsRepository: SpiritsRepository
    private let userRepository: UserRepository

    // MARK: - Initialization
    init(jobsRepository: JobsRepository, spiritsRepository: SpiritsRepository, userRepository: UserRepository) {
        self.jobsRepository = jobsRepository
        self.spiritsRepository = spiritsRepository
        self.userRepository = userRepository
    }

    // MARK: - Computed Properties (View에서 읽기 전용)

    /// 현재 선택된 직업 ID (DB에서 불러온 값)
    var selectedJob: String {
        currentJobs.selectedJob
    }

    /// 현재 선택된 직업 타입 (DB에서 불러온 값)
    var selectedJobType: JobType {
        currentJobs.selectedJobType
    }

    /// 현재 선택된 직업의 표시 이름
    var currentJobName: String {
        selectedJobType.displayName
    }

    /// 현재 보고 있는 job의 스텟 (TabView에서 현재 표시되는 job 기준)
    var currentJobStats: JobStats {
        JobStats.getStats(for: selectedJobType.rawValue)
    }

    /// 현재 직업의 체력 스텟
    var hp: Int {
        currentJobStats.hp
    }

    /// 현재 직업의 에너지 스텟
    var energy: Int {
        currentJobStats.energy
    }

    /// 현재 직업의 이동속도 스텟
    var move: Int {
        currentJobStats.move
    }

    /// 현재 직업의 공격속도 스텟
    var attackSpeed: Int {
        currentJobStats.attackSpeed
    }

    // MARK: - Public Methods (외부에서 호출 가능)

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

    /// 직업 데이터 재조회 (최신 데이터 새로고침)
    func refreshJobs() async {
        guard !currentJobs.playerId.isEmpty else {
            print("⚔️ Jobs: 재조회 실패 - playerID가 없습니다")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if let refreshedJobs = try await jobsRepository.getJobs(by: currentJobs.playerId) {
                currentJobs = refreshedJobs
                print("⚔️ Jobs: 직업 데이터 재조회 성공")
            } else {
                print("⚔️ Jobs: 재조회 실패 - 직업 데이터를 찾을 수 없습니다")
            }
        } catch {
            self.error = error
            print("⚔️ Jobs: 직업 데이터 재조회 실패 - \(error.localizedDescription)")
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

    // MARK: - Job Unlock Business Logic

    /// 직업 해금 (외부에서 호출)
    func unlockJob(_ jobType: JobType) async {
        let stats = JobStats.getStats(for: jobType.rawValue)

        guard let requirement = stats.unlockRequirement else {
            // 해금 조건이 없는 경우 (novice 등)
            await unlockJobDirectly(jobType)
            return
        }

        // 정령 개수 및 레벨 확인
        guard await canUnlockJob(requirement) else {
            let currentCount = await getCurrentSpiritCount(for: requirement.spiritType)
            let currentLevel = await getCurrentUserLevel()

            if currentCount < requirement.count && currentLevel < requirement.requiredLevel {
                print("💎 직업 해금 실패: \(requirement.spiritType) 정령 \(requirement.count)개와 Lv.\(requirement.requiredLevel)이 필요합니다")
            } else if currentCount < requirement.count {
                print("💎 직업 해금 실패: \(requirement.spiritType) 정령이 \(requirement.count)개 필요합니다 (현재: \(currentCount)개)")
            } else if currentLevel < requirement.requiredLevel {
                print("💎 직업 해금 실패: Lv.\(requirement.requiredLevel)이 필요합니다 (현재: Lv.\(currentLevel))")
            }
            return
        }

        // 정령 개수 차감 및 해금
        await unlockJobWithSpirits(requirement, jobType: jobType)
        // ✅ refresh는 콜백을 통해 자동으로 수행됨
    }

    /// 해금 조건 확인
    private func canUnlockJob(_ requirement: JobUnlockRequirement) async -> Bool {
        // 정령 개수 확인
        let currentCount = await getCurrentSpiritCount(for: requirement.spiritType)
        let hasEnoughSpirits = currentCount >= requirement.count

        // 레벨 확인
        let currentLevel = await getCurrentUserLevel()
        let hasRequiredLevel = currentLevel >= requirement.requiredLevel

        return hasEnoughSpirits && hasRequiredLevel
    }

    /// 정령 소비 및 직업 해금
    private func unlockJobWithSpirits(_ requirement: JobUnlockRequirement, jobType: JobType) async {
        // 정령 개수 차감
        await consumeSpirits(for: requirement.spiritType, count: requirement.count)
        // 직업 해금
        await unlockJobDirectly(jobType)
        print("🔥 직업 \(jobType.displayName) 해금 완료! \(requirement.spiritType) 정령 \(requirement.count)개 소비")
    }

    /// 정령 개수 차감
    private func consumeSpirits(for spiritType: String, count: Int) async {
        do {
            _ = try await spiritsRepository.addSpirit(
                for: currentJobs.playerId,
                spiritType: SpiritType(rawValue: spiritType) ?? .fire,
                count: -count
            )
            print("🔥 정령 차감 완료: \(spiritType) \(count)개")
        } catch {
            self.error = error
            print("🔥 정령 차감 실패: \(error.localizedDescription)")
        }
    }

    /// 직업 직접 해금 (조건 없이)
    private func unlockJobDirectly(_ jobType: JobType) async {
        do {
            currentJobs = try await jobsRepository.unlockJob(for: currentJobs.playerId, jobType: jobType)
            print("🔓 직업 \(jobType.displayName) 해금됨")
        } catch {
            self.error = error
            print("🔓 직업 해금 실패: \(error.localizedDescription)")
        }
    }

    /// 현재 정령 개수 조회
    private func getCurrentSpiritCount(for spiritType: String) async -> Int {
        do {
            if let spirits = try await spiritsRepository.getSpirits(by: currentJobs.playerId) {
                return getSpiritCount(for: spiritType, from: spirits)
            }
        } catch {
            self.error = error
            print("🔥 정령 조회 실패: \(error.localizedDescription)")
        }
        return 0
    }

    /// 정령 개수 추출 헬퍼
    private func getSpiritCount(for spiritType: String, from spirits: Spirits) -> Int {
        switch spiritType {
        case "fire": return spirits.fire
        case "ice": return spirits.ice
        case "lightning": return spirits.lightning
        case "dark": return spirits.dark
        default: return 0
        }
    }

    /// 현재 사용자 레벨 조회
    private func getCurrentUserLevel() async -> Int {
        do {
            if let user = try await userRepository.getUser(by: currentJobs.playerId) {
                return Level(currentExp: user.exp).currentLevel
            }
        } catch {
            self.error = error
            print("👤 사용자 레벨 조회 실패: \(error.localizedDescription)")
        }
        return 0
    }

    // MARK: - Debug/Test Methods (개발용)

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

    /// 직업 초기화 (기본 상태로 되돌림)
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

    /// 현재 직업 정보 출력 (디버깅용)
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
