import Foundation
import SpriteKit
import CoreGraphics

// MARK: - Game Constants
struct GameConstants {
    
    // MARK: - Physics
    struct Physics {
        static let worldWidth: CGFloat = 2000
        static let worldHeight: CGFloat = 2000
        static let playerLinearDamping: CGFloat = 0.1
        static let zombieLinearDamping: CGFloat = 0.3
    }
    
    // MARK: - Player
    struct Player {
        static let size = CGSize(width: 30, height: 30)  // 20% 축소된 사이즈
        static let maxHealth: Int = 100
        static let maxAmmo: Int = 30
        static let reloadTime: TimeInterval = 2.0
        static let damagePerHit: Int = 10
        static let baseMoveSpeed: CGFloat = 180.0
        static let waveSpeedBonus: CGFloat = 10.0  // 웨이브당 속도 증가량
        static let maxWaveSpeedBonus: CGFloat = 100.0  // 최대 웨이브 속도 보너스
        
        // 플레이어 이미지 관련 상수들 제거됨 - 네온 사각형 사용
    }
    
    // MARK: - Bullet
    struct Bullet {
        static let size = CGSize(width: 4, height: 4)
        static let speed: CGFloat = 1000
        static let lifetime: TimeInterval = 3.0
        static let damage: Int = 25
        
        // 네온 효과 설정
        static let neonColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.9)
        static let neonStrokeColor = SKColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
        static let coreColor = SKColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
        static let glowWidth: CGFloat = 2.0
        static let coreGlowWidth: CGFloat = 1.0
        
        // 파티클 효과 설정
        static let sparkleColor = SKColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
        static let sparkleStrokeColor = SKColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
        static let particleLifetime: TimeInterval = 0.5 // 파티클 효과 지속 시간
        
        // Impact 파티클 세부 설정
        static let particleBirthRate: CGFloat = 500.0
        static let particleCount: Int = 50
        static let particleLifetimeBase: CGFloat = 0.25
        static let particleLifetimeRange: CGFloat = 0.1
        static let particleSpeed: CGFloat = 250
        static let particleSpeedRange: CGFloat = 100
        static let particleScale: CGFloat = 0.3
        static let particleScaleRange: CGFloat = 0.2
        static let particleScaleSpeed: CGFloat = -1.5
        static let particleAlpha: CGFloat = 0.9
        static let particleAlphaSpeed: CGFloat = -3.5
    }
    
    // MARK: - Zombie
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
        
        static let spawnDistance: CGFloat = 100
        static let baseSpawnInterval: TimeInterval = 2.0
        static let minSpawnInterval: TimeInterval = 0.5
        static let spawnIntervalDecrement: TimeInterval = 0.1
        
        // 좀비 이미지 관련 상수들 제거됨 - 네온 사각형 사용
    }
    
    // MARK: - Toast Message
    struct ToastMessage {
        static let fontSize: CGFloat = 20
        static let offsetY: CGFloat = 50  // 플레이어 머리 위 거리
        static let defaultDuration: TimeInterval = 2.0
        static let shadowOffset = CGPoint(x: 1, y: -1)
        static let zPosition: CGFloat = 500
        
        // 애니메이션 설정
        static let appearDuration: TimeInterval = 0.2
        static let disappearDuration: TimeInterval = 0.3
        static let appearMoveDistance: CGFloat = 10
        static let disappearMoveDistance: CGFloat = 15
        static let initialScale: CGFloat = 0.5
        static let finalScale: CGFloat = 0.8
        
        // 스택 관리 설정
        static let stackSpacing: CGFloat = 30  // 토스트 간 간격
        static let stackAnimationDuration: TimeInterval = 0.2
        static let stackScaleReduction: CGFloat = 0.15  // 15%씩 작아짐
        static let stackAlphaReduction: CGFloat = 0.2  // 20%씩 투명해짐
        static let minStackScale: CGFloat = 0.4  // 최소 40%
        static let minStackAlpha: CGFloat = 0.3  // 최소 30%
        static let repositionDuration: TimeInterval = 0.3
        static let quickRemovalDuration: TimeInterval = 0.1
        static let quickRemovalScale: CGFloat = 0.1
    }
    
    // MARK: - Items
    struct Items {
        static let size = CGSize(width: 35, height: 35)
        static let baseSpawnCount: Int = 6  // 초기 아이템 수 증가
        static let spawnCountMultiplier: Float = 1.8  // 웨이브마다 50% 증가
        static let maxSpawnCount: Int = 80  // 최대 아이템 수 증가
        static let spawnInterval: TimeInterval = 3.0  // 4초마다 새 아이템 스폰 (더 자주)
        static let lifetime: TimeInterval = 40.0  // 35초 후 아이템 사라짐 (더 오래)
        static let zPosition: CGFloat = 5
        static let spawnMargin: CGFloat = 100  // 맵 가장자리에서 떨어진 거리
        
        // 아이템 효과 지속시간
        static let buffDuration: TimeInterval = 7.0
        
        // 즉시 효과 아이템 수치
        static let healthRestoreAmount: Int = 30
        static let ammoRestoreAmount: Int = 30
        
        // 버프 효과 수치
        static let speedMultiplier: CGFloat = 1.5
        static let shotgunBulletCount: Int = 5
        static let shotgunSpreadAngle: CGFloat = 70  // 도 단위
        
        // 메테오 효과 수치 (새로운 폭탄 시스템)
        static let meteorDamage: Int = 999  // 즉사 데미지        
        static let meteorDelayBeforeExplosion: TimeInterval = 1.0  // 아이템 사용 후 폭발까지 대기 시간
        
        // 메테오 경고 표시기
        static let meteorIndicatorSize: CGFloat = 30  // 경고 표시기 크기 (시야 방해 최소화)
        static let meteorWarningColor = SKColor.orange  // 경고 색상
        static let meteorWarningLineWidth: CGFloat = 2  // 경고 링 두께
        static let meteorWarningGlowWidth: CGFloat = 3  // 경고 글로우 효과
        static let meteorWarningAlpha: CGFloat = 0.8  // 경고 투명도
        static let meteorCenterDotSize: CGFloat = 3  // 중앙 점 크기
        
        // 메테오 폭발 효과 (맵 전체를 커버하는 강력한 폭발)
        static let meteorExplosionRadius: CGFloat = 800  // 폭발 반지름 (맵 대부분을 커버)
        static let meteorInnerExplosionRadius: CGFloat = 600  // 내부 폭발 반지름
        static let meteorCenterFlashRadius: CGFloat = 400  // 중앙 플래시 반지름
        static let meteorExplosionDuration: TimeInterval = 0.3  // 폭발 지속시간
        static let meteorExplosionScale: CGFloat = 1.2  // 폭발 최대 스케일 (과하지 않게)
        static let meteorExplosionLineWidth: CGFloat = 4  // 폭발 링 두께
        static let meteorExplosionGlowWidth: CGFloat = 6  // 폭발 글로우 효과
        static let meteorExplosionOuterColor = SKColor.red  // 외부 폭발 색상
        static let meteorExplosionInnerColor = SKColor.yellow  // 내부 폭발 색상
        
        // 아이템별 최소 웨이브 요구사항
        static let speedBoostMinWave: Int = 2  // 웨이브 2부터 등장
        static let invincibilityMinWave: Int = 3  // 웨이브 3부터 등장
        static let shotgunMinWave: Int = 3  // 웨이브 3부터 등장
        static let meteorMinWave: Int = 5  // 웨이브 5부터 등장
        
        // 아이템 이미지 설정
        static let ammoRestoreImageName = "item_ammoRestore"
        static let healthRestoreImageName = "item_healthRestore"
        static let invincibilityImageName = "item_invincibility"
        static let meteorImageName = "item_meteor"
        static let shotgunImageName = "item_shotgun"
        static let speedBoostImageName = "item_speedboost"
    }
    
    // MARK: - UI Layout
    struct UI {
        static let safeAreaMargin: CGFloat = 30
        static let joystickRadius: CGFloat = 50
        static let joystickThumbRadius: CGFloat = 20
        static let fireButtonRadius: CGFloat = 40
        static let fireButtonSize: CGFloat = 80
        static let joystickDeadzone: CGFloat = 10
        static let controlMargin: CGFloat = 100  // 조이스틱과 버튼의 화면 가장자리 마진
        static let controlZPosition: CGFloat = 100  // 컨트롤 UI의 z-position
        
        // HUD
        static let hudMargin: CGFloat = 20
        static let barWidth: CGFloat = 150
        static let barHeight: CGFloat = 20
        static let labelFontSize: CGFloat = 18
        
        // HUD Colors
        static let healthBarColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)  // 네온 그린
        static let ammoBarColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8)   // 네온 시안
        static let reloadLabelColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)  // 네온 오렌지
        static let ammoReloadingColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)  // 재장전 중 색상
        
        // Health Bar Color Gradients
        static let healthHighColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)   // 네온 그린
        static let healthMediumColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8) // 네온 옐로우
        static let healthLowColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)    // 네온 레드
        
        // GameOver
        static let gameOverBackgroundSize = CGSize(width: 800, height: 600)
        static let gameOverTitleFontSize: CGFloat = 48
        static let gameOverLabelFontSize: CGFloat = 24
        static let gameOverButtonSize = CGSize(width: 120, height: 40)
        static let gameOverButtonFontSize: CGFloat = 18
        
        // Navigation
        static let transitionDuration: Double = 0.3
    }
    
    // MARK: - Colors
    struct Colors {
        // Player
        static let playerColor = "blue"
        
        // Zombies
        static let normalZombieColor = "red"
        static let fastZombieColor = "orange"
        static let strongZombieColor = "purple"
        
        // Bullets
        static let bulletColor = "yellow"
        
        // UI
        static let joystickBaseColor = "white"
        static let joystickThumbColor = "gray"
        static let fireButtonColor = "red"
        
        // HUD
        static let healthColorHigh = "green"
        static let healthColorMedium = "yellow"
        static let healthColorLow = "red"
        static let ammoColorNormal = "blue"
        static let ammoColorReloading = "orange"
    }
    
    // MARK: - Neon Effects
    struct NeonEffects {
        // Player Neon
        static let playerNeonColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0) // 네온 시안
        static let playerGlowWidth: CGFloat = 2
        
        // Zombie Neon Colors
        static let normalZombieNeonColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0) // 네온 그린
        static let fastZombieNeonColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0) // 네온 마젠타
        static let strongZombieNeonColor = SKColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 1.0) // 네온 오렌지-레드
        static let zombieGlowWidth: CGFloat = 2
        
        // Grid Neon
        static let gridNeonColor = SKColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 0.4) // 네온 시안 (투명)
        static let gridHighlightColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.6) // 밝은 네온 시안
        static let gridGlowWidth: CGFloat = 1
        
        // Border Neon
        static let borderNeonColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.8) // 네온 마젠타
        static let borderGlowColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.3) // 글로우 마젠타
        static let borderGlowWidth: CGFloat = 2
        
        // Background
        static let cyberpunkBackgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0) // 진한 네이비/블랙
    }
    
    // MARK: - Node Names
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
    

    
    // MARK: - Text
    struct Text {
        static let gameOver = "게임 오버"
        static let playTime = "플레이 시간: %02d:%02d"
        static let zombieKills = "좀비 처치: %d마리"
        static let wave = "웨이브: %d"
        static let restart = "다시하기"
        static let quit = "그만하기"
        static let score = "Score: %d"
        static let time = "%02d:%02d"
        static let health = "Health"
        static let ammo = "Ammo"
        static let reloading = "재장전 중..."
        static let waveAnnouncement = "웨이브 %d"
        static let exitButton = "나가기"
    }
    
    // MARK: - Wave System
    struct Wave {
        static let duration: TimeInterval = 30.0  // 30초마다 웨이브 증가
        static let announcementDuration: TimeInterval = 2.0  // 웨이브 알림 표시 시간
        static let zombieCountMultiplier: Float = 1.4  // 웨이브마다 좀비 수 40% 증가
        static let speedMultiplier: Float = 1.13  // 웨이브마다 좀비 속도 13% 증가
        static let healthMultiplier: Float = 1.08  // 웨이브마다 좀비 체력 8% 증가
        static let maxSpeedMultiplier: Float = 3.0  // 최대 속도 배수
        static let maxHealthMultiplier: Float = 5.0  // 최대 체력 배수
    }
    
    // MARK: - Map System (Grid-based)
    struct Map {
        static let backgroundZPosition: CGFloat = -100
        static let gridZPosition: CGFloat = -90  // 그리드 라인 z-position
        static let borderZPosition: CGFloat = -80  // 네온 테두리 z-position
        
        // 그리드 설정
        static let gridSpacing: CGFloat = 100  // 그리드 간격 (기존 하드코딩 값과 동일)
        static let gridLineWidth: CGFloat = 1.0  // 그리드 선 두께
        static let borderLineWidth: CGFloat = 4.0  // 테두리 선 두께 (기존 하드코딩 값과 동일)
    }
    
    // MARK: - Game Balance
    struct Balance {
        static let scorePerKill: Int = 1
        static let zombieNormalSpawnRate: Int = 60  // 60%
        static let zombieFastSpawnRate: Int = 25    // 25%
        static let zombieStrongSpawnRate: Int = 15  // 15%
    }
    
    // MARK: - Audio
    struct Audio {
        // 배경음악 설정
        struct BackgroundMusic {
            static let mainMenuTrack = "main_background"
            static let gameTrack = "game_background"
            static let fileExtension = "mp3"
            static let volume: Float = 0.2
        }
        
        // 효과음 설정 (SKAction 사용)
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
    
    // MARK: - Haptic
    struct Haptic {
        // 햅틱 강도 설정
        static let shootIntensity: Float = 0.8      // 발사 시 약한 진동
        static let shotgunIntensity: Float = 1.0    // 샷건 발사 시 강한 진동
        static let hitIntensity: Float = 1.0        // 피격 시 중간 진동
        static let itemIntensity: Float = 1.0       // 아이템 수집 시 약한 진동
        static let buttonIntensity: Float = 1.0     // 버튼 터치 시 매우 약한 진동
    }
}
