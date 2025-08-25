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
        static let title = "게임 오버"
        static let playTimeFormat = "플레이 시간: %02d:%02d"
        static let zombieKillsFormat = "네모 처치: %d마리"
        static let restartButton = "다시하기"
        static let quitButton = "그만하기"
    }
    
    // MARK: - HUD Display
    struct HUD {
        static let scoreFormat = "Score: %d"
        static let timeFormat = "%02d:%02d"
        static let health = "Health"
        static let ammo = "Ammo"
        static let reloading = "재장전 중..."
    }
    
    // MARK: - Wave System
    struct Wave {
        static let waveFormat = "웨이브: %d"
        static let waveAnnouncementFormat = "웨이브 %d"
    }
    
    // MARK: - UI Elements
    struct UI {
        static let exitButton = "나가기"
        static let fireButton = "FIRE"
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
        static let meteor = "Meteor"
        static let joystickBase = "JoystickBase"
        static let joystickThumb = "JoystickThumb"
        static let fireButton = "FireButton"
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
        
        static let currentLeaderboardID = LeaderboardIDs.basic
    }
}
