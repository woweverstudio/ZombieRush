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
    private let elementsRepository: ElementsRepository
    private let jobsRepository: JobsRepository

    // MARK: - Initialization
    init(userRepository: UserRepository,
         statsRepository: StatsRepository,
         elementsRepository: ElementsRepository,
         jobsRepository: JobsRepository) {
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.elementsRepository = elementsRepository
        self.jobsRepository = jobsRepository

        print("🔧 UseCaseFactory: 외부에서 주입받은 Repository들로 초기화 완료")
    }

    // MARK: - Repository Access (for Views to observe state)
    var repositories: (user: UserRepository, stats: StatsRepository, elements: ElementsRepository, jobs: JobsRepository) {
        (userRepository, statsRepository, elementsRepository, jobsRepository)
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

    // MARK: - Elements UseCases
    var loadOrCreateElements: LoadOrCreateElementsUseCase {
        LoadOrCreateElementsUseCase(elementsRepository: elementsRepository)
    }

    var refreshElements: RefreshElementsUseCase {
        RefreshElementsUseCase(elementsRepository: elementsRepository)
    }

    var updateElements: UpdateElementsUseCase {
        UpdateElementsUseCase(elementsRepository: elementsRepository)
    }

    var addElement: AddElementUseCase {
        AddElementUseCase(elementsRepository: elementsRepository, userRepository: userRepository)
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
        UnlockJobUseCase(jobsRepository: jobsRepository, elementsRepository: elementsRepository, userRepository: userRepository)
    }

    var loadJobRequirements: LoadJobRequirementsUseCase {
        LoadJobRequirementsUseCase()
    }
}
