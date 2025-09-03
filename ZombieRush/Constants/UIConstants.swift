//
//  UIConstants.swift
//  ZombieRush
//
//  UI-related constants including layout, colors, and visual effects
//

import Foundation
import SpriteKit
import CoreGraphics

struct UIConstants {
    
    // MARK: - Layout & Positioning
    struct Layout {
        static let safeAreaMargin: CGFloat = 30
        static let controlMargin: CGFloat = 100
        static let hudMargin: CGFloat = 20
    }
    
    // MARK: - Controls
    struct Controls {
        static let joystickRadius: CGFloat = 50
        static let joystickThumbRadius: CGFloat = 20
        static let fireButtonRadius: CGFloat = 40
        static let fireButtonSize: CGFloat = 80
        static let joystickDeadzone: CGFloat = 10
        static let controlZPosition: CGFloat = 100
    }
    
    // MARK: - HUD Elements
    struct HUD {
        static let barWidth: CGFloat = 150
        static let barHeight: CGFloat = 20
        static let labelFontSize: CGFloat = 18
    }
    
    // MARK: - Toast Messages
    struct Toast {
        static let fontSize: CGFloat = 20
        static let offsetY: CGFloat = 50
        static let defaultDuration: TimeInterval = 2.0
        static let shadowOffset = CGPoint(x: 1, y: -1)
        static let zPosition: CGFloat = 500
        
        // Animation Settings
        static let appearDuration: TimeInterval = 0.2
        static let disappearDuration: TimeInterval = 0.3
        static let appearMoveDistance: CGFloat = 10
        static let disappearMoveDistance: CGFloat = 15
        static let initialScale: CGFloat = 0.5
        static let finalScale: CGFloat = 0.8
        
        // Stack Management
        static let stackSpacing: CGFloat = 30
        static let stackAnimationDuration: TimeInterval = 0.2
        static let stackScaleReduction: CGFloat = 0.15
        static let stackAlphaReduction: CGFloat = 0.2
        static let minStackScale: CGFloat = 0.4
        static let minStackAlpha: CGFloat = 0.3
        static let repositionDuration: TimeInterval = 0.3
        static let quickRemovalDuration: TimeInterval = 0.1
        static let quickRemovalScale: CGFloat = 0.1
    }
    
    // MARK: - Game Over Screen
    struct GameOver {
        static let backgroundSize = CGSize(width: 800, height: 600)
        static let titleFontSize: CGFloat = 48
        static let labelFontSize: CGFloat = 24
        static let buttonSize = CGSize(width: 120, height: 40)
        static let buttonFontSize: CGFloat = 18
    }
    
    // MARK: - Map Visual
    struct Map {
        static let backgroundZPosition: CGFloat = -100
        static let gridZPosition: CGFloat = -90
        static let borderZPosition: CGFloat = -80
        static let gridSpacing: CGFloat = 100
        static let gridLineWidth: CGFloat = 1.0
        static let borderLineWidth: CGFloat = 4.0
    }
    
    // MARK: - Item Visual
    struct ItemVisual {
        static let zPosition: CGFloat = 5
        static let meteorIndicatorSize: CGFloat = 30
        static let meteorWarningLineWidth: CGFloat = 2
        static let meteorWarningGlowWidth: CGFloat = 3
        static let meteorWarningAlpha: CGFloat = 0.8
        static let meteorCenterDotSize: CGFloat = 3
        static let meteorExplosionLineWidth: CGFloat = 4
        static let meteorExplosionGlowWidth: CGFloat = 6
    }
    
    // MARK: - Particle Effects
    struct ParticleEffects {
        static let bulletParticleLifetime: TimeInterval = 0.5
        static let bulletParticleBirthRate: CGFloat = 500.0
        static let bulletParticleCount: Int = 50
        static let bulletParticleLifetimeBase: CGFloat = 0.25
        static let bulletParticleLifetimeRange: CGFloat = 0.1
        static let bulletParticleSpeed: CGFloat = 250
        static let bulletParticleSpeedRange: CGFloat = 100
        static let bulletParticleScale: CGFloat = 0.3
        static let bulletParticleScaleRange: CGFloat = 0.2
        static let bulletParticleScaleSpeed: CGFloat = -1.5
        static let bulletParticleAlpha: CGFloat = 0.9
        static let bulletParticleAlphaSpeed: CGFloat = -3.5
    }
    
    // MARK: - Animations
    struct Animation {
        static let transitionDuration: Double = 0.3
    }
    
    // MARK: - Haptic Feedback
    struct Haptic {
        static let shootIntensity: Float = 0.8
        static let shotgunIntensity: Float = 1.0
        static let hitIntensity: Float = 1.0
        static let itemIntensity: Float = 1.0
        static let buttonIntensity: Float = 1.0
    }
    
    // MARK: - Colors
    struct Colors {
        
        // MARK: - Neon Effects
        struct Neon {
            // Player
            static let playerColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
            static let playerGlowWidth: CGFloat = 2
            
            // Bullets
            static let bulletColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.9)
            static let bulletStrokeColor = SKColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
            static let bulletCoreColor = SKColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
            static let bulletGlowWidth: CGFloat = 2.0
            static let bulletCoreGlowWidth: CGFloat = 1.0
            static let bulletSparkleColor = SKColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
            static let bulletSparkleStrokeColor = SKColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
            
            // Zombies
            static let normalZombieColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)
            static let fastZombieColor = SKColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0)
            static let strongZombieColor = SKColor(red: 1.0, green: 0.2, blue: 0.35, alpha: 1.0)
            static let zombieGlowWidth: CGFloat = 2
            
            // Grid
            static let gridColor = SKColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 0.4)
            static let gridHighlightColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.6)
            static let gridGlowWidth: CGFloat = 1
            
            // Border
            static let borderColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.8)
            static let borderGlowColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.3)
            static let borderGlowWidth: CGFloat = 2
            
            // Background
            static let cyberpunkBackgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        }
        
        // MARK: - HUD Colors
        struct HUD {
            static let healthBarColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)
            static let ammoBarColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8)
            static let reloadLabelColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            static let ammoReloadingColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
            
            // Health Bar Gradients
            static let healthHighColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)
            static let healthMediumColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8)
            static let healthLowColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)
        }
        
        // MARK: - Item Colors
        struct Items {
            static let meteorWarningColor = SKColor.orange
            static let meteorExplosionOuterColor = SKColor.red
            static let meteorExplosionInnerColor = SKColor.yellow
        }
        
        // MARK: - Legacy String Colors (for backward compatibility)
        struct Legacy {
            static let playerColor = "blue"
            static let normalZombieColor = "red"
            static let fastZombieColor = "orange"
            static let strongZombieColor = "purple"
            static let bulletColor = "yellow"
            static let joystickBaseColor = "white"
            static let joystickThumbColor = "gray"
            static let fireButtonColor = "red"
            static let healthColorHigh = "green"
            static let healthColorMedium = "yellow"
            static let healthColorLow = "red"
            static let ammoColorNormal = "blue"
            static let ammoColorReloading = "orange"
        }
    }
}
