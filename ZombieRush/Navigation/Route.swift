import Foundation

// MARK: - Route Enum
enum Route: String, CaseIterable, Hashable {
    case loading = "loading"
    case mainMenu = "main_menu"
    case game = "game"
    case settings = "settings"
    case leaderboard = "leaderboard"
    case gameOver = "game_over"
    
    var title: String {
        switch self {
        case .loading:
            return "LOADING..."
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
    var currentRoute: Route = .loading  // 로딩 화면으로 시작
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
    let playTime: Int
    let score: Int
    let success: Bool
    
    init(playTime: Int = 0, score: Int = 0, success: Bool = false) {
        self.playTime = playTime
        self.score = score
        self.success = success
    }
}
