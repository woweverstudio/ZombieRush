//
//  UseCaseFactory.swift
//  ZombieRush
//
//  Created by UseCase Factory for centralized UseCase management
//

/// UseCase Factory - 중앙집중식 UseCase 관리
/// Repositories를 싱글턴으로 관리하고 UseCase들을 computed property로 제공
import SwiftUI

final class UseCaseFactory: ObservableObject {
    // MARK: - Repositories (SSOT - Single Source of Truth)
    private let userRepository: UserRepository
    private let statsRepository: StatsRepository
    private let spiritsRepository: SpiritsRepository
    private let jobsRepository: JobsRepository

    // MARK: - Initialization
    init(userRepository: UserRepository,
         statsRepository: StatsRepository,
         spiritsRepository: SpiritsRepository,
         jobsRepository: JobsRepository) {
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.spiritsRepository = spiritsRepository
        self.jobsRepository = jobsRepository

        print("🔧 UseCaseFactory: 외부에서 주입받은 Repository들로 초기화 완료")
    }

    // MARK: - Repository Access (for Views to observe state)
    var repositories: (user: UserRepository, stats: StatsRepository, spirits: SpiritsRepository, jobs: JobsRepository) {
        (userRepository, statsRepository, spiritsRepository, jobsRepository)
    }

    // MARK: - User UseCases
    var loadOrCreateUser: LoadOrCreateUserUseCase {
        LoadOrCreateUserUseCase(userRepository: userRepository)
    }

    var updateUser: UpdateUserUseCase {
        UpdateUserUseCase(userRepository: userRepository)
    }

    var refreshUser: RefreshUserUseCase {
        RefreshUserUseCase(userRepository: userRepository)
    }

    var addExperience: AddExperienceUseCase {
        AddExperienceUseCase(userRepository: userRepository)
    }

    var consumeNemoFruits: ConsumeNemoFruitsUseCase {
        ConsumeNemoFruitsUseCase(userRepository: userRepository)
    }

    var addNemoFruits: AddNemoFruitsUseCase {
        AddNemoFruitsUseCase(userRepository: userRepository)
    }

    var purchaseCheerBuff: PurchaseCheerBuffUseCase {
        PurchaseCheerBuffUseCase(userRepository: userRepository)
    }

    var consumeRemainingPoints: ConsumeRemainingPointsUseCase {
        ConsumeRemainingPointsUseCase(userRepository: userRepository)
    }

    // MARK: - Stats UseCases
    var loadOrCreateStats: LoadOrCreateStatsUseCase {
        LoadOrCreateStatsUseCase(statsRepository: statsRepository)
    }

    var refreshStats: RefreshStatsUseCase {
        RefreshStatsUseCase(statsRepository: statsRepository)
    }

    var upgradeStat: UpgradeStatUseCase {
        UpgradeStatUseCase(statsRepository: statsRepository, userRepository: userRepository)
    }

    // MARK: - Spirits UseCases
    var loadOrCreateSpirits: LoadOrCreateSpiritsUseCase {
        LoadOrCreateSpiritsUseCase(spiritsRepository: spiritsRepository)
    }

    var refreshSpirits: RefreshSpiritsUseCase {
        RefreshSpiritsUseCase(spiritsRepository: spiritsRepository)
    }

    var updateSpirits: UpdateSpiritsUseCase {
        UpdateSpiritsUseCase(spiritsRepository: spiritsRepository)
    }

    var addSpirit: AddSpiritUseCase {
        AddSpiritUseCase(spiritsRepository: spiritsRepository, userRepository: userRepository)
    }

    // MARK: - Jobs UseCases
    var loadOrCreateJobs: LoadOrCreateJobsUseCase {
        LoadOrCreateJobsUseCase(jobsRepository: jobsRepository)
    }

    var refreshJobs: RefreshJobsUseCase {
        RefreshJobsUseCase(jobsRepository: jobsRepository)
    }

    var updateJobs: UpdateJobsUseCase {
        UpdateJobsUseCase(jobsRepository: jobsRepository)
    }

    var selectJob: SelectJobUseCase {
        SelectJobUseCase(jobsRepository: jobsRepository)
    }

    var unlockJob: UnlockJobUseCase {
        UnlockJobUseCase(jobsRepository: jobsRepository, spiritsRepository: spiritsRepository, userRepository: userRepository)
    }

    var loadJobRequirements: LoadJobRequirementsUseCase {
        LoadJobRequirementsUseCase()
    }
}
