//
//  TextConstants.swift
//  ZombieRush
//
//  All text constants and localization strings
//

import Foundation

struct TextConstants {
    
    // MARK: - Game Over Screen
    struct GameOver {
        static let title = NSLocalizedString("GAME_OVER_TITLE", comment: "Game over screen title")
        static let playTimeFormat = NSLocalizedString("GAME_OVER_PLAY_TIME_FORMAT", comment: "Play time format")
        static let zombieKillsFormat = NSLocalizedString("GAME_OVER_ZOMBIE_KILLS_FORMAT", comment: "Zombie kills format")
        static let restartButton = NSLocalizedString("GAME_OVER_RESTART_BUTTON", comment: "Restart game button")
        static let quitButton = NSLocalizedString("GAME_OVER_QUIT_BUTTON", comment: "Quit game button")
    }

    // MARK: - Ultimate System
    struct Ultimate {
        static let ultimateReady = NSLocalizedString("ULTIMATE_READY", comment: "Ultimate skill is ready to use")
    }

    // MARK: - HUD Display
    struct HUD {
        static let scoreFormat = NSLocalizedString("HUD_SCORE_FORMAT", comment: "Score display format")
        static let timeFormat = NSLocalizedString("HUD_TIME_FORMAT", comment: "Time display format")
        static let health = NSLocalizedString("HUD_HEALTH", comment: "Health label")
        static let ammo = NSLocalizedString("HUD_AMMO", comment: "Ammo label")
        static let reloading = NSLocalizedString("HUD_RELOADING", comment: "Reloading status text")
    }

    // MARK: - Wave System
    struct Wave {
        static let waveFormat = NSLocalizedString("WAVE_FORMAT", comment: "Wave display format")
        static let waveAnnouncementFormat = NSLocalizedString("WAVE_ANNOUNCEMENT_FORMAT", comment: "Wave announcement format")
    }

    // MARK: - UI Elements
    struct UI {
        static let exitButton = NSLocalizedString("UI_EXIT_BUTTON", comment: "Exit button text")
        static let fireButton = NSLocalizedString("UI_FIRE_BUTTON", comment: "Fire button text")
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
        static let skeletonMessage = NSLocalizedString("SKELETON_MESSAGE", comment: "Skeleton row message")

        struct GameStartTooltips {
            static let notLoggedIn = NSLocalizedString("GAME_START_TOOLTIP_NOT_LOGGED_IN", comment: "Game start tooltip when not logged in")
            static let loggedIn = NSLocalizedString("GAME_START_TOOLTIP_LOGGED_IN", comment: "Game start tooltip when logged in")
            static let top3 = NSLocalizedString("GAME_START_TOOLTIP_TOP3", comment: "Game start tooltip when in top 3")
        }
    }
}
