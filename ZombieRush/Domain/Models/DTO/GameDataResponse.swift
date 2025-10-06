import Foundation

// MARK: - Game Data Response from RPC
struct GameData: Codable {
    let user: User
    let stats: Stats
    let elements: Elements
    let jobs: Jobs
    let jobRequirements: [JobUnlockRequirement]

    enum CodingKeys: String, CodingKey {
        case user
        case stats
        case elements
        case jobs
        case jobRequirements = "job_requirements"
    }
}
