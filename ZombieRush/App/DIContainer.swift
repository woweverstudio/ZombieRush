//
//  DIContainer.swift
//  ZombieRush
//
//  Created by 김민성 on 2025.
//

import Foundation

/// 의존성 주입 컨테이너 - Repository들을 중앙에서 관리
final class DIContainer {
    // MARK: - Shared Instance
    static let shared = DIContainer()

    // MARK: - Repository Instances (싱글턴)
    let userRepository: UserRepository
    let statsRepository: StatsRepository
    let spiritsRepository: SpiritsRepository
    let jobsRepository: JobsRepository

    // MARK: - Private Init
    private init() {
        // Repository 인스턴스만 생성 (콜백 연결은 StateManager 생성 시점에)
        self.userRepository = SupabaseUserRepository()
        self.statsRepository = SupabaseStatsRepository()
        self.spiritsRepository = SupabaseSpiritsRepository()
        self.jobsRepository = SupabaseJobsRepository()

        print("🔧 DIContainer: Repository들 초기화 완료")
    }

    // MARK: - StateManager Factory Methods (@Observable 호환을 위해)
    func makeUserStateManager() -> UserStateManager {
        let userManager = UserStateManager(
            userRepository: userRepository,
            spiritsRepository: spiritsRepository
        )

        // ✅ StateManager 생성 직후 콜백 연결
        userRepository.onDataChanged = { [weak userManager] in
            await userManager?.refreshUser()
        }

        return userManager
    }

    func makeStatsStateManager() -> StatsStateManager {
        let statsManager = StatsStateManager(
            statsRepository: statsRepository,
            userRepository: userRepository
        )

        // ✅ StateManager 생성 직후 콜백 연결
        statsRepository.onDataChanged = { [weak statsManager] in
            await statsManager?.refreshStats()
        }

        return statsManager
    }

    func makeSpiritsStateManager() -> SpiritsStateManager {
        let spiritsManager = SpiritsStateManager(spiritsRepository: spiritsRepository)

        // ✅ StateManager 생성 직후 콜백 연결
        spiritsRepository.onDataChanged = { [weak spiritsManager] in
            await spiritsManager?.refreshSpirits()
        }

        return spiritsManager
    }

    func makeJobsStateManager() -> JobsStateManager {
        let jobsManager = JobsStateManager(
            jobsRepository: jobsRepository,
            spiritsRepository: spiritsRepository,
            userRepository: userRepository
        )

        // ✅ StateManager 생성 직후 콜백 연결
        jobsRepository.onDataChanged = { [weak jobsManager] in
            await jobsManager?.refreshJobs()
        }

        return jobsManager
    }

}
