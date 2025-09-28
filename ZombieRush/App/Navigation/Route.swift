import Foundation

// MARK: - 내 정보 카테고리
enum MyInfoCategory: String, CaseIterable {
    case jobs
    case stats
    case spirits
}

// MARK: - Localized Extensions
extension MyInfoCategory {
    var localizedDisplayName: String {
        switch self {
        case .jobs:
            return NSLocalizedString("myinfo_category_jobs", tableName: "Models", comment: "MyInfo jobs category display name")
        case .stats:
            return NSLocalizedString("myinfo_category_stats", tableName: "Models", comment: "MyInfo stats category display name")
        case .spirits:
            return NSLocalizedString("myinfo_category_spirits", tableName: "Models", comment: "MyInfo spirits category display name")
        }
    }
}

// MARK: - Route Enum (Associated Values 추가)
enum Route: Hashable {
    case loading
    case serviceUnavailable
    case story
    case main
    case game
    case settings
    case leaderboard
    case market
    case myInfo(category: MyInfoCategory)
    case gameOver(playTime: Int, score: Int, success: Bool)

    var title: String {
        switch self {
        case .loading:
            return "LOADING..."
        case .serviceUnavailable:
            return "SERVICE UNAVAILABLE"
        case .story:
            return "STORY"
        case .main:
            return "NEMO NEMO BEAM"
        case .game:
            return "GAME"
        case .settings:
            return "SETTINGS"
        case .leaderboard:
            return "LEADERBOARD"
        case .market:
            return "MARKET"
        case .myInfo:
            return "MYINFO"
        case .gameOver:
            return "GAME OVER"
        }
    }

    var identifier: String {
        switch self {
        case .loading: return "loading"
        case .serviceUnavailable: return "service_unavailable"
        case .story: return "story"
        case .main: return "main"
        case .game: return "game"
        case .settings: return "settings"
        case .leaderboard: return "leaderboard"
        case .market: return "market"
        case .myInfo: return "my_info"
        case .gameOver: return "game_over"
        }
    }
}
