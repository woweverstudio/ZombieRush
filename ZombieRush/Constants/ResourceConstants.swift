//
//  ResourceConstants.swift
//  ZombieRush
//
//  All resource constants including images, sounds, and other assets
//

import Foundation

struct ResourceConstants {
    
    // MARK: - Audio Resources
    struct Audio {
        
        // MARK: - Background Music
        struct BackgroundMusic {
            static let mainMenuTrack = "main_background"
            static let gameTrack = "game_background"
            static let fileExtension = "mp3"
            static let volume: Float = 0.2
        }
        
        // MARK: - Sound Effects
        struct SoundEffects {
            static let shoot = "shoot.wav"
            static let shotgun = "shotgun.wav"
            static let reload = "reload.wav"
            static let button = "button.mp3"
            static let item = "item.wav"
            static let meteor = "meteor.wav"
            static let hit = "hit.wav"
        }
    }
    
    // MARK: - Image Resources
    struct Images {
        
        // MARK: - Item Images
        struct Items {
            static let ammoRestore = "item_ammoRestore"
            static let healthRestore = "item_healthRestore"
            static let invincibility = "item_invincibility"
            static let meteor = "item_meteor"
            static let shotgun = "item_shotgun"
            static let speedBoost = "item_speedboost"
        }
        
        // MARK: - UI Images
        struct UI {
            static let background = "background"
            static let gameOver = "gameover"
        }
        
        // MARK: - Character Faces
        struct Faces {
            static let normal = "face_normal"
            static let happy = "face_happy"
            static let angry = "face_angry"
            static let hit = "face_hit"
        }
        
        // MARK: - Effects
        struct Effects {
            static let spark = "spark"
            static let bokeh = "bokeh"
        }
        
        // MARK: - App Icon
        struct AppIcon {
            static let icon = "u9784866189_cute_2.5D_isometric_arcade_scene_a_cyan_protagoni_c6425efd-eb83-4e54-8a53-3c5fac0072b2_0"
        }
    }
    
    // MARK: - Particle Effects
    struct ParticleEffects {
        static let bulletImpact = "BulletImpact"
    }
    
    // MARK: - Font Resources
    struct Fonts {
        static let arialBold = "Arial-Bold"
    }
}
