//
//  TextConstants.swift
//  ZombieRush
//
//  All text constants and localization strings
//

import Foundation

struct TextConstants {

    // MARK: - Force Update
    struct ForceUpdate {
        static let newVersionAvailable = NSLocalizedString("NEW_VERSION_AVAILABLE", comment: "Force update screen - New version available message")
        static let goToAppStore = NSLocalizedString("GO_TO_APP_STORE", comment: "Force update screen - Go to App Store button")
    }

    // MARK: - Loading Screen
    struct Loading {
        static let checkingVersion = NSLocalizedString("CHECKING_VERSION", comment: "Loading screen - Version check in progress")
        static let loadingData = NSLocalizedString("LOADING_DATA", comment: "Loading screen - Loading data text")
        static let readyToPlay = NSLocalizedString("READY_TO_PLAY", comment: "Loading screen - Ready to play text")
    }

    // MARK: - Game Over Screen
    struct GameOver {
        static let title = NSLocalizedString("GAME_OVER_TITLE", comment: "Game over screen title")
        static let newRecordTitle = NSLocalizedString("GAME_OVER_NEW_RECORD_TITLE", comment: "New record achieved title")
        static let playTimeFormat = NSLocalizedString("GAME_OVER_PLAY_TIME_FORMAT", comment: "Play time format")
        static let zombieKillsFormat = NSLocalizedString("GAME_OVER_ZOMBIE_KILLS_FORMAT", comment: "Zombie kills format")
        static let restartButton = NSLocalizedString("GAME_OVER_RESTART_BUTTON", comment: "Restart game button")
        static let quitButton = NSLocalizedString("GAME_OVER_QUIT_BUTTON", comment: "Quit game button")

        // GameOverView에서 사용하는 추가 텍스트들
        static let playTimeLabel = NSLocalizedString("GAME_OVER_PLAY_TIME_LABEL", comment: "Play time label in game over view")
        static let killsLabel = NSLocalizedString("GAME_OVER_KILLS_LABEL", comment: "Kills label in game over view")
        static let firstRecord = NSLocalizedString("GAME_OVER_FIRST_RECORD", comment: "First record message")
        static let recordExceededFormat = NSLocalizedString("GAME_OVER_RECORD_EXCEEDED_FORMAT", comment: "Record exceeded format")
        static let recordShortageFormat = NSLocalizedString("GAME_OVER_RECORD_SHORTAGE_FORMAT", comment: "Record shortage format")
        static let tieRecord = NSLocalizedString("GAME_OVER_TIE_RECORD", comment: "Tie record message")
    }

    // MARK: - Game Start
    struct GameStart {
        static let message = NSLocalizedString("GAME_START_MESSAGE", comment: "Game Start Message")
        static let titleLine1 = NSLocalizedString("GAME_TITLE_LINE1", comment: "First line of game title")
        static let titleLine2 = NSLocalizedString("GAME_TITLE_LINE2", comment: "Second line of game title")
    }

    // MARK: - Ultimate System
    struct Ultimate {
        static let ultimateReady = NSLocalizedString("ULTIMATE_READY", comment: "Ultimate skill is ready to use")
        static let nuclearActivated = NSLocalizedString("ULTIMATE_NUCLEAR_ACTIVATED", comment: "Nuclear attack activated")
    }

    // MARK: - HUD Display
    struct HUD {
        static let scoreFormat = NSLocalizedString("HUD_SCORE_FORMAT", comment: "Score display format")
        static let timeFormat = NSLocalizedString("HUD_TIME_FORMAT", comment: "Time display format")
        static let health = NSLocalizedString("HUD_HEALTH", comment: "Health label")
        static let ammo = NSLocalizedString("HUD_AMMO", comment: "Ammo label")
        static let reloading = NSLocalizedString("HUD_RELOADING", comment: "Reloading status text")

        // HUDManager specific
        static let scoreInitial = NSLocalizedString("HUD_SCORE_INITIAL", comment: "Initial score display")
        static let timeInitial = NSLocalizedString("HUD_TIME_INITIAL", comment: "Initial time display")
        static let healthLabel = NSLocalizedString("HUD_HEALTH_LABEL", comment: "Health label")
        static let ammoLabel = NSLocalizedString("HUD_AMMO_LABEL", comment: "Ammo label")
        static let reloadingLabel = NSLocalizedString("HUD_RELOADING_LABEL", comment: "Reloading label")
    }

    // MARK: - Wave System
    struct Wave {
        static let waveAnnouncementFormat = NSLocalizedString("WAVE_ANNOUNCEMENT_FORMAT", comment: "Wave announcement format")
    }


    // MARK: - Pause
    struct Pause {
        static let title = NSLocalizedString("PAUSE_TITLE", comment: "Pause overlay - Paused title")
        static let quitButton = NSLocalizedString("PAUSE_QUIT_BUTTON", comment: "Pause overlay - Quit button text")
        static let resumeButton = NSLocalizedString("PAUSE_RESUME_BUTTON", comment: "Pause overlay - Resume button text")
    }

    // MARK: - Settings
    struct Settings {
        static let title = NSLocalizedString("SETTINGS_TITLE", comment: "Settings screen title")
        static let soundEffects = NSLocalizedString("SETTINGS_SOUND_EFFECTS", comment: "Sound effects setting")
        static let backgroundMusic = NSLocalizedString("SETTINGS_BACKGROUND_MUSIC", comment: "Background music setting")
        static let vibration = NSLocalizedString("SETTINGS_VIBRATION", comment: "Vibration setting")
    }

    // MARK: - Leaderboard
    struct Leaderboard {
        static let title = NSLocalizedString("LEADERBOARD_TITLE", comment: "Leaderboard screen title")
        static let errorTitle = NSLocalizedString("LEADERBOARD_ERROR_TITLE", comment: "Leaderboard error title")
        static let errorMessage = NSLocalizedString("LEADERBOARD_ERROR_MESSAGE", comment: "Leaderboard error message")
        static let retryButton = NSLocalizedString("RETRY_BUTTON", comment: "Retry button text")
        static let skeletonMessage = NSLocalizedString("SKELETON_MESSAGE", comment: "Leaderboard skeleton message")
    }

    // MARK: - Hall of Fame
    struct HallOfFame {
        static let title = NSLocalizedString("HALL_OF_FAME_TITLE", comment: "Hall of Fame Card Title")
        static let loginPrompt = NSLocalizedString("LOGIN_PROMPT_HALL_OF_FAME", comment: "Login prompt for Hall of Fame Card")
    }

    // MARK: - Player Card
    struct PlayerCard {
        static let playTimeLabel = NSLocalizedString("PLAY_TIME_LABEL", comment: "Player Card - Play Time Label")
        static let rankLabel = NSLocalizedString("RANK_LABEL", comment: "Player Card - Rank Label")
        static let killsLabel = NSLocalizedString("KILLS_LABEL", comment: "Player Card - Kills Label")
    }

    // MARK: - Profile
    struct Profile {
        static let settingsPath = NSLocalizedString("PROFILE_SETTINGS_PATH", comment: "Player Profile Card")
    }

    // MARK: - Login Prompts
    struct LoginPrompt {
        static let playerCard = NSLocalizedString("LOGIN_PROMPT_PLAYER_CARD", comment: "Login prompt for Player Card")
    }

    // MARK: - Item Effects
    struct ItemEffect {
        struct Collection {
            static let speedBoost = NSLocalizedString("ITEM_SPEED_BOOST_COLLECT", comment: "Speed boost item collected")
            static let healthRestore = NSLocalizedString("ITEM_HEALTH_RESTORE_COLLECT", comment: "Health restore item collected")
            static let ammoRestore = NSLocalizedString("ITEM_AMMO_RESTORE_COLLECT", comment: "Ammo restore item collected")
            static let invincibility = NSLocalizedString("ITEM_INVINCIBILITY_COLLECT", comment: "Invincibility item collected")
            static let shotgun = NSLocalizedString("ITEM_SHOTGUN_COLLECT", comment: "Shotgun item collected")
        }

        struct End {
            static let speedBoost = NSLocalizedString("ITEM_SPEED_BOOST_END", comment: "Speed boost effect ended")
            static let invincibility = NSLocalizedString("ITEM_INVINCIBILITY_END", comment: "Invincibility effect ended")
            static let shotgun = NSLocalizedString("ITEM_SHOTGUN_END", comment: "Shotgun effect ended")
        }
    }


    // MARK: - Errors
    struct Error {
        static let genericNetwork = NSLocalizedString("GENERIC_NETWORK_ERROR", comment: "Generic network error")
        static let gameKitNotAuthenticated = NSLocalizedString("GAMEKIT_NOT_AUTHENTICATED", comment: "GameKit not authenticated error")
        static let gameKitNetworkError = NSLocalizedString("GAMEKIT_NETWORK_ERROR", comment: "GameKit network error")
        static let gameKitLeaderboardNotFound = NSLocalizedString("GAMEKIT_LEADERBOARD_NOT_FOUND", comment: "Leaderboard not found error")
        static let gameKitGeneric = NSLocalizedString("GAMEKIT_GENERIC_ERROR", comment: "Generic GameKit error")
    }

    // MARK: - Notifications
    struct Notification {
        static let hallOfFameChallenge = NSLocalizedString("NOTIFICATION_HALL_OF_FAME_CHALLENGE", comment: "Weekly notification to challenge Hall of Fame")
    }

    // MARK: - App Info
    struct App {
        static let title = NSLocalizedString("APP_TITLE", comment: "App display name for notifications")
    }

    // MARK: - Date/Time
    struct DateTime {
        static let weekFormat = NSLocalizedString("WEEK_FORMAT", comment: "Week format for date display")
    }

    // MARK: - Game Center
    struct GameCenter {
        struct LeaderboardIDs {
            static let basic = "nnb_basic_ranking"
            // Future maps
            // static let desert = "nnb_desert_ranking"
            // static let city = "nnb_city_ranking"
            // static let space = "nnb_space_ranking"
        }

        static let currentLeaderboardID = "weekly_global_top100"

        struct GameStartTooltips {
            static let notLoggedIn = NSLocalizedString("GAME_START_TOOLTIP_NOT_LOGGED_IN", comment: "Game start tooltip when not logged in")
            static let loggedIn = NSLocalizedString("GAME_START_TOOLTIP_LOGGED_IN", comment: "Game start tooltip when logged in")
            static let top3 = NSLocalizedString("GAME_START_TOOLTIP_TOP3", comment: "Game start tooltip when in top 3")
        }
    }

    // MARK: - Node Names (for SpriteKit identification)
    struct NodeNames {
        static let world = "World"
        static let camera = "Camera"
        static let player = "Player"
        static let bullet = "Bullet"
        static let zombie = "Zombie"
        static let gameOverUI = "GameOverUI"
        static let restartButton = "RestartButton"
        static let quitButton = "QuitButton"
        static let toastMessage = "ToastMessage"
        static let item = "Item"
        static let joystickBase = "JoystickBase"
        static let joystickThumb = "JoystickThumb"
        static let fireButton = "FireButton"
        static let ultimateButton = "UltimateButton"
        static let ultimateButtonRing = "UltimateButtonRing"
        static let playerShape = "PlayerShape"
        static let zombieShape = "ZombieShape"
        static let faceExpression = "FaceExpression"
        static let hud = "HUD"
        static let cyberpunkBackground = "CyberpunkBackground"
        static let neonBorder = "NeonBorder"
        static let neonBorderGlow = "NeonBorderGlow"
    }
}
