import Foundation

// MARK: - Route Enum (Associated Values 추가)
enum Route: Hashable {
    case loading
    case main
    case game
    case settings
    case leaderboard
    case gameOver(playTime: Int, score: Int, success: Bool)

    var title: String {
        switch self {
        case .loading:
            return "LOADING..."
        case .main:
            return "NEMO NEMO BEAM"
        case .game:
            return "GAME"
        case .settings:
            return "SETTINGS"
        case .leaderboard:
            return "LEADERBOARD"
        case .gameOver:
            return "GAME OVER"
        }
    }

    var identifier: String {
        switch self {
        case .loading: return "loading"
        case .main: return "main"
        case .game: return "game"
        case .settings: return "settings"
        case .leaderboard: return "leaderboard"
        case .gameOver: return "game_over"
        }
    }
}

// MARK: - Game Data Transfer Object
struct GameData {
    let playTime: Int
    let score: Int
    let success: Bool
    
    init(playTime: Int = 0, score: Int = 0, success: Bool = false) {
        self.playTime = playTime
        self.score = score
        self.success = success
    }
}
