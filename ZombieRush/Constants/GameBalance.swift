//
//  GameBalance.swift
//  ZombieRush
//
//  Game balance constants including difficulty, abilities, and progression
//

import Foundation
import CoreGraphics

struct GameBalance {
    
    // MARK: - Physics
    struct Physics {
        static let worldWidth: CGFloat = 2000
        static let worldHeight: CGFloat = 2000
        static let playerLinearDamping: CGFloat = 0.1
        static let zombieLinearDamping: CGFloat = 0.3
    }
    
    // MARK: - Player Stats
    struct Player {
        static let size = CGSize(width: 30, height: 30)
        static let maxHealth: Int = 100
        static let maxAmmo: Int = 30
        static let reloadTime: TimeInterval = 2.0
        static let damagePerHit: Int = 10
        static let baseMoveSpeed: CGFloat = 180.0
        static let waveSpeedBonus: CGFloat = 10.0
        static let maxWaveSpeedBonus: CGFloat = 100.0
    }
    
    // MARK: - Bullet Stats
    struct Bullet {
        static let size = CGSize(width: 4, height: 4)
        static let speed: CGFloat = 1000
        static let lifetime: TimeInterval = 3.0
        static let damage: Int = 25
    }
    
    // MARK: - Zombie Stats
    struct Zombie {
        static let normalSize = CGSize(width: 20, height: 20)
        static let fastSize = CGSize(width: 15, height: 15)
        static let strongSize = CGSize(width: 30, height: 30)
        
        static let normalSpeed: CGFloat = 50
        static let fastSpeed: CGFloat = 80
        static let strongSpeed: CGFloat = 30
        
        static let normalHealth: Int = 25
        static let fastHealth: Int = 15
        static let strongHealth: Int = 60
        
        static let spawnDistance: CGFloat = 10
        static let baseSpawnInterval: TimeInterval = 0.6
        static let minSpawnInterval: TimeInterval = 0.1
        static let spawnIntervalDecrementPerWave: TimeInterval = 0.05
        
        // Spawn Rates
        static let normalSpawnRate: Int = 60  // 60%
        static let fastSpawnRate: Int = 25    // 25%
        static let strongSpawnRate: Int = 15  // 15%

        // Zombie Count Limits
        static let baseMaxZombies: Int = 40
        static let additionalZombiesPerWave: Int = 10
        static let maxZombieLimit: Int = 150
    }
    
    // MARK: - Item Effects
    struct Items {
        static let size = CGSize(width: 35, height: 35)
        static let baseSpawnCount: Int = 8
        static let spawnCountMultiplier: Float = 2.0
        static let maxSpawnCount: Int = 80
        static let spawnInterval: TimeInterval = 2.0
        static let lifetime: TimeInterval = 40.0
        static let spawnMargin: CGFloat = 100
        
        // Effect Durations
        static let buffDuration: TimeInterval = 7.0
        
        // Instant Effects
        static let healthRestoreAmount: Int = 30
        static let ammoRestoreAmount: Int = 30
        
        // Buff Effects
        static let speedMultiplier: CGFloat = 1.2
        static let shotgunBulletCount: Int = 5
        static let shotgunSpreadAngle: CGFloat = 70
        static let shotgunDamage: Int = 999
        
        // Meteor Effects
        static let meteorDamage: Int = 999
        static let meteorDelayBeforeExplosion: TimeInterval = 1.0
        static let meteorExplosionRadius: CGFloat = 800
        static let meteorInnerExplosionRadius: CGFloat = 600
        static let meteorCenterFlashRadius: CGFloat = 400
        static let meteorExplosionDuration: TimeInterval = 0.3
        static let meteorExplosionScale: CGFloat = 1.2
        
        // Item Wave Requirements
        static let speedBoostMinWave: Int = 2
        static let invincibilityMinWave: Int = 3
        static let shotgunMinWave: Int = 3
        static let meteorMinWave: Int = 4
    }
    
    // MARK: - Wave System
    struct Wave {
        static let duration: TimeInterval = 30.0
        static let announcementDuration: TimeInterval = 2.0
        static let speedMultiplier: Float = 1.13
        static let healthMultiplier: Float = 1.1
        static let maxSpeedMultiplier: Float = 3.5
        static let maxHealthMultiplier: Float = 5.5
    }
    
    // MARK: - Scoring
    struct Score {
        static let perKill: Int = 1
    }
    

}
