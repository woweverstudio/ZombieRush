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
    private let alertManager: AlertManager

    // MARK: - Initialization
    init(userRepository: UserRepository,
         statsRepository: StatsRepository,
         elementsRepository: ElementsRepository,
         jobsRepository: JobsRepository,
         transactionRepository: TransactionRepository,
         alertManager: AlertManager
    ) {
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.elementsRepository = elementsRepository
        self.jobsRepository = jobsRepository
        self.transactionRepository = transactionRepository
        self.alertManager = alertManager
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
    
    var loginAsGuest: LoginAsGuestUseCase {
        LoginAsGuestUseCase(userRepository: userRepository,
                            statsRepository: statsRepository,
                            elementsRepository: elementsRepository,
                            jobsRepository: jobsRepository)
    }

    var addExperience: AddExperienceUseCase {
        AddExperienceUseCase(userRepository: userRepository,
                             alertManager: alertManager)
    }

    var upgradeStat: UpgradeStatUseCase {
        UpgradeStatUseCase(statsRepository: statsRepository,
                           userRepository: userRepository,
                           alertManager: alertManager)
    }

    var addElement: AddElementUseCase {
        AddElementUseCase(elementsRepository: elementsRepository,
                          userRepository: userRepository,
                          alertManager: alertManager)
    }
    
    var addGem: AddGemUseCase {
        AddGemUseCase(userRepository: userRepository,
                      alertManager: alertManager)
    }

    var selectJob: SelectJobUseCase {
        SelectJobUseCase(jobsRepository: jobsRepository)
    }

    var unlockJob: UnlockJobUseCase {
        UnlockJobUseCase(jobsRepository: jobsRepository,
                         elementsRepository: elementsRepository,
                         userRepository: userRepository,
                         alertManager: alertManager)
    }

    var saveTransaction: SaveTransactionUseCase {
        SaveTransactionUseCase(transactionRepository: transactionRepository,
                               userRepository: userRepository,
                               alertManager: alertManager)
    }
}
