//
//  LoginAsGuestUseCase.swift
//  ZombieRush
//
//  Created by 김민성 on 10/6/25.
//

import Foundation


@MainActor
struct LoginAsGuestUseCase {
    let userRepository: UserRepository
    let statsRepository: StatsRepository
    let elementsRepository: ElementsRepository
    let jobsRepository: JobsRepository
    
    func execute() {
        let user = User(playerId: "", nickname: "Guest")
        let stats = Stats(playerId: "")
        let elements = Elements(playerId: "")
        let jobs = Jobs(playerId: "")
        let jobUnlockRequirements = [
            JobUnlockRequirement(jobKey: "fire", requiredLevel: 5, requiredElement: "fire", requiredCount: 15),
            JobUnlockRequirement(jobKey: "ice", requiredLevel: 10, requiredElement: "ice", requiredCount: 20),
            JobUnlockRequirement(jobKey: "thunder", requiredLevel: 15, requiredElement: "thunder", requiredCount: 25),
            JobUnlockRequirement(jobKey: "dark", requiredLevel: 20, requiredElement: "dark", requiredCount: 30)
        ]

        userRepository.currentUser = user
        statsRepository.currentStats = stats
        elementsRepository.currentElements = elements
        jobsRepository.currentJobs = jobs
        JobUnlockRequirement.loadRequirements(jobUnlockRequirements)
        
        return
    }
}
