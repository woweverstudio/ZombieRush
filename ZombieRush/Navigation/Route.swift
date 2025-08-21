import Foundation

// MARK: - Route Enum
enum Route: String, CaseIterable, Hashable {
    case mainMenu = "main_menu"
    case game = "game"
    case settings = "settings"
    case leaderboard = "leaderboard"
    case gameOver = "game_over"
    
    var title: String {
        switch self {
        case .mainMenu:
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
        return rawValue
    }
}

// MARK: - Navigation State
struct NavigationState {
    var currentRoute: Route = .mainMenu
    var previousRoute: Route?
    var gameData: GameData?
    
    mutating func navigate(to route: Route, with data: GameData? = nil) {
        previousRoute = currentRoute
        currentRoute = route
        gameData = data
    }
    
    mutating func goBack() {
        if let previous = previousRoute {
            currentRoute = previous
            previousRoute = nil
            gameData = nil
        }
    }
}

// MARK: - Game Data Transfer Object
struct GameData {
    let playTime: TimeInterval
    let score: Int
    let wave: Int
    let isRestart: Bool
    let isNewRecord: Bool
    
    init(playTime: TimeInterval = 0, score: Int = 0, wave: Int = 0, isRestart: Bool = false, isNewRecord: Bool = false) {
        self.playTime = playTime
        self.score = score
        self.wave = wave
        self.isRestart = isRestart
        self.isNewRecord = isNewRecord
    }
}
