import Foundation

// MARK: - Request/Response
struct LoadGameDataRequest {
    let playerID: String
    let nickname: String
}

public struct LoadGameDataResponse {
    let success: Bool
}

// MARK: - Load Game Data Use Case
@MainActor
struct LoadGameDataUseCase: UseCase {
    typealias Request = LoadGameDataRequest
    typealias Response = LoadGameDataResponse

    private let userRepository: UserRepository
    private let statsRepository: StatsRepository
    private let elementsRepository: ElementsRepository
    private let jobsRepository: JobsRepository

    init(
        userRepository: UserRepository,
        statsRepository: StatsRepository,
        elementsRepository: ElementsRepository,
        jobsRepository: JobsRepository
    ) {
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.elementsRepository = elementsRepository
        self.jobsRepository = jobsRepository
    }

    func execute(_ request: Request) async -> Response {
        do {
            // Repository를 통해 RPC 호출 및 디코딩
            let gameData = try await userRepository.loadGameData(
                playerID: request.playerID,
                nickname: request.nickname
            )
            
            userRepository.currentUser = gameData.user
            statsRepository.currentStats = gameData.stats
            elementsRepository.currentElements = gameData.elements
            jobsRepository.currentJobs = gameData.jobs
            
            JobUnlockRequirement.loadRequirements(gameData.jobRequirements)

            return LoadGameDataResponse(success: true)
        } catch {
            return LoadGameDataResponse(success: false)
        }
    }
}

