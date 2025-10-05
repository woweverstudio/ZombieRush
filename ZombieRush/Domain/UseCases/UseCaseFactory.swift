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
    private let transactionRepository: TransactionRepository

    // MARK: - Initialization
    init(userRepository: UserRepository,
         statsRepository: StatsRepository,
         elementsRepository: ElementsRepository,
         jobsRepository: JobsRepository,
         transactionRepository: TransactionRepository) {
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.elementsRepository = elementsRepository
        self.jobsRepository = jobsRepository
        self.transactionRepository = transactionRepository
    }

    // MARK: - Repository Access (for Views to observe state)
    var repositories: (user: UserRepository, stats: StatsRepository, elements: ElementsRepository, jobs: JobsRepository, transaction: TransactionRepository) {
        (userRepository, statsRepository, elementsRepository, jobsRepository, transactionRepository)
    }
    
    @MainActor
    var loadGameData: LoadGameDataUseCase {
        LoadGameDataUseCase(userRepository: userRepository,
                            statsRepository: statsRepository,
                            elementsRepository: elementsRepository,
                            jobsRepository: jobsRepository)
    }

    var addExperience: AddExperienceUseCase {
        AddExperienceUseCase(userRepository: userRepository)
    }

    var upgradeStat: UpgradeStatUseCase {
        UpgradeStatUseCase(statsRepository: statsRepository, userRepository: userRepository)
    }

    var updateElements: UpdateElementsUseCase {
        UpdateElementsUseCase(elementsRepository: elementsRepository)
    }

    var addElement: AddElementUseCase {
        AddElementUseCase(elementsRepository: elementsRepository, userRepository: userRepository)
    }
    
    var addGem: AddGemUseCase {
        AddGemUseCase(userRepository: userRepository)
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

    var saveTransaction: SaveTransactionUseCase {
        SaveTransactionUseCase(transactionRepository: transactionRepository, userRepository: userRepository)
    }
}
