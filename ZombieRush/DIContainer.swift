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
        // Repository 인스턴스만 생성 (StateManager들은 각 사용처에서 생성)
        self.userRepository = SupabaseUserRepository()
        self.statsRepository = SupabaseStatsRepository()
        self.spiritsRepository = SupabaseSpiritsRepository()
        self.jobsRepository = SupabaseJobsRepository()

        print("🔧 DIContainer: Repository들 초기화 완료")
    }

    // MARK: - StateManager Factory Methods (@Observable 호환을 위해)
    func makeUserStateManager() -> UserStateManager {
        UserStateManager(
            userRepository: userRepository,
            spiritsRepository: spiritsRepository
        )
    }

    func makeStatsStateManager() -> StatsStateManager {
        StatsStateManager(statsRepository: statsRepository)
    }

    func makeSpiritsStateManager() -> SpiritsStateManager {
        SpiritsStateManager(spiritsRepository: spiritsRepository)
    }

    func makeJobsStateManager() -> JobsStateManager {
        JobsStateManager(jobsRepository: jobsRepository)
    }

}
