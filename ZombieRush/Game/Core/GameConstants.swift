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
        static let size = CGSize(width: 50, height: 50)
        static let maxHealth: Int = 100
        static let maxAmmo: Int = 30
        static let reloadTime: TimeInterval = 2.0
        static let damagePerHit: Int = 10
        static let baseMoveSpeed: CGFloat = 180.0
        static let waveSpeedBonus: CGFloat = 10.0  // 웨이브당 속도 증가량
        static let maxWaveSpeedBonus: CGFloat = 100.0  // 최대 웨이브 속도 보너스
        
        // 플레이어 이미지 설정
        static let leftImageName = "player_left"
        static let rightImageName = "player_right"
        static let defaultDirection: PlayerDirection = .left
        
        // 방향 전환 기준각도 (도 단위)
        static let directionThreshold: CGFloat = 90  // 90도를 기준으로 좌우 판단
        
        enum PlayerDirection {
            case left
            case right
            
            var imageName: String {
                switch self {
                case .left:
                    return Player.leftImageName
                case .right:
                    return Player.rightImageName
                }
            }
        }
    }
    
    // MARK: - Bullet
    struct Bullet {
        static let size = CGSize(width: 6, height: 12)
        static let speed: CGFloat = 1200
        static let lifetime: TimeInterval = 3.0
        static let damage: Int = 25
    }
    
    // MARK: - Zombie
    struct Zombie {
        static let normalSize = CGSize(width: 60, height: 60)
        static let fastSize = CGSize(width: 60, height: 60)
        static let strongSize = CGSize(width: 80, height: 80)
        
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
        
        // 좀비 이미지 설정
        static let normalLeftImage = "zombie_basic_left"
        static let normalRightImage = "zombie_basic_right"
        static let fastLeftImage = "zombie_fast_left"
        static let fastRightImage = "zombie_fast_right"
        static let strongLeftImage = "zombie_strong_left"
        static let strongRightImage = "zombie_strong_right"
        
        // 방향 전환 기준
        static let directionThreshold: CGFloat = 90  // 90도를 기준으로 좌우 판단
        
        enum ZombieDirection {
            case left
            case right
        }
    }
    
    // MARK: - Toast Message
    struct ToastMessage {
        static let fontSize: CGFloat = 20
        static let offsetY: CGFloat = 70  // 플레이어 머리 위 거리
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
        static let baseSpawnCount: Int = 15  // 초기 아이템 수 증가
        static let spawnCountMultiplier: Float = 1.5  // 웨이브마다 50% 증가
        static let maxSpawnCount: Int = 80  // 최대 아이템 수 증가
        static let spawnInterval: TimeInterval = 4.0  // 4초마다 새 아이템 스폰 (더 자주)
        static let lifetime: TimeInterval = 35.0  // 35초 후 아이템 사라짐 (더 오래)
        static let zPosition: CGFloat = 5
        static let spawnMargin: CGFloat = 100  // 맵 가장자리에서 떨어진 거리
        
        // 아이템 효과 지속시간
        static let buffDuration: TimeInterval = 7.0
        
        // 즉시 효과 아이템 수치
        static let healthRestoreAmount: Int = 30
        static let ammoRestoreAmount: Int = 15
        
        // 버프 효과 수치
        static let speedMultiplier: CGFloat = 1.5
        static let shotgunBulletCount: Int = 5
        static let shotgunSpreadAngle: CGFloat = 70  // 도 단위
        
        // 메테오 효과 수치
        static let meteorDuration: TimeInterval = 8.0  // 8초간 지속
        static let meteorSpawnInterval: TimeInterval = 0.2  // 0.2초마다 운석 생성 (매우 빠름)
        static let meteorRadius: CGFloat = 300  // 플레이어 주변 300px 반경 (더 확대)
        static let meteorDamage: Int = 999  // 즉사 데미지
        static let meteorSize: CGFloat = 70  // 운석 크기 (더 확대)
        static let meteorFallSpeed: CGFloat = 1200  // 낙하 속도 (더 빠름)
        static let meteorMinWave: Int = 5  // 웨이브 5부터 등장
        
        // 메테오 애니메이션 수치
        static let meteorFireEffectOffset: CGFloat = 15  // 불꽃 효과 추가 반지름
        static let meteorLineWidth: CGFloat = 4  // 테두리 두께
        static let meteorFallDuration: TimeInterval = 0.7  // 낙하 시간
        static let meteorRotationDuration: TimeInterval = 1.0  // 회전 시간
        static let meteorExplosionRadius: CGFloat = 80  // 폭발 반지름
        static let meteorInnerExplosionRadius: CGFloat = 40  // 내부 폭발 반지름
        static let meteorExplosionDuration: TimeInterval = 0.4  // 폭발 지속시간
        static let meteorExplosionScale: CGFloat = 4.0  // 폭발 최대 스케일
        static let meteorRemovalScale: CGFloat = 2.0  // 제거 시 스케일
        static let meteorRemovalDuration: TimeInterval = 0.2  // 제거 애니메이션 시간
        
        // 아이템별 최소 웨이브 요구사항
        static let speedBoostMinWave: Int = 2  // 웨이브 2부터 등장
        static let invincibilityMinWave: Int = 3  // 웨이브 3부터 등장
        static let shotgunMinWave: Int = 3  // 웨이브 3부터 등장
        
        // 아이템 이미지 설정
        static let speedBoostImageName = "item_speedBoost"
        static let healthRestoreImageName = "item_healthRestore"
        static let ammoRestoreImageName = "item_ammoRestore"
        static let invincibilityImageName = "item_invincibility"
        static let shotgunImageName = "item_shotgun"
        static let meteorImageName = "item_meteor"
    }
    
    // MARK: - World Border (그림자 효과)
    struct WorldBorder {
        static let borderWidth: CGFloat = 3           // 얇은 경계선
        static let borderAlpha: CGFloat = 0.7         // 진한 그림자 효과 (0.4 → 0.7)
        static let lineWidth: CGFloat = 1             // 테두리 두께
        static let shadowColor = SKColor.black        // 그림자 색상
    }
    
    // MARK: - UI Layout
    struct UI {
        static let safeAreaMargin: CGFloat = 30
        static let joystickRadius: CGFloat = 50
        static let joystickThumbRadius: CGFloat = 20
        static let fireButtonRadius: CGFloat = 40
        static let joystickDeadzone: CGFloat = 10
        
        // HUD
        static let hudMargin: CGFloat = 20
        static let barWidth: CGFloat = 150
        static let barHeight: CGFloat = 20
        static let labelFontSize: CGFloat = 18
        
        // GameOver
        static let gameOverBackgroundSize = CGSize(width: 800, height: 600)
        static let gameOverTitleFontSize: CGFloat = 48
        static let gameOverLabelFontSize: CGFloat = 24
        static let gameOverButtonSize = CGSize(width: 120, height: 40)
        static let gameOverButtonFontSize: CGFloat = 18
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
    
    // MARK: - Notification Names
    struct Notifications {
        static let quitGame = "QuitGame"
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
        static let time = "Time: %02d:%02d"
        static let health = "Health"
        static let ammo = "Ammo"
        static let reloading = "재장전 중..."
        static let waveAnnouncement = "웨이브 %d"
    }
    
    // MARK: - Wave System
    struct Wave {
        static let duration: TimeInterval = 30.0  // 30초마다 웨이브 증가
        static let announcementDuration: TimeInterval = 2.0  // 웨이브 알림 표시 시간
        static let zombieCountMultiplier: Float = 1.4  // 웨이브마다 좀비 수 40% 증가
        static let speedMultiplier: Float = 1.15  // 웨이브마다 좀비 속도 15% 증가
        static let healthMultiplier: Float = 1.25  // 웨이브마다 좀비 체력 25% 증가
        static let maxSpeedMultiplier: Float = 3.0  // 최대 속도 배수
        static let maxHealthMultiplier: Float = 5.0  // 최대 체력 배수
    }
    
    // MARK: - Map System
    struct Map {
        static let defaultMapName = "map"
        static let boundaryImageName = "mapBoundary"
        static let backgroundZPosition: CGFloat = -100
        static let boundaryZPosition: CGFloat = -110  // 맵 배경보다 더 뒤에
        
        // 맵 품질 설정
        static let maxScaleFactor: CGFloat = 2.0  // 최대 확대 비율 (화질 보존)
        static let minScaleFactor: CGFloat = 0.5  // 최소 축소 비율
        
        // 경계 설정
        static let boundaryThickness: CGFloat = 1000  // 경계 영역 두께
        static let boundaryOverflow: CGFloat = 500    // 경계가 맵 밖으로 얼마나 확장될지
        static let useTiledBoundary: Bool = true      // 타일링 방식 사용 여부
        static let defaultTileSize: CGFloat = 128     // 기본 타일 크기 (원본 이미지가 이 크기라고 가정)
        
        // 맵 타일 설정 (향후 확장용)
        static let tileSize: CGFloat = 512  // 맵 이미지를 타일로 나누어 사용할 때
        
        // 맵 종류 (향후 확장용)
        enum MapType: String, CaseIterable {
            case jungle = "map"
            // case desert = "desert_map"
            // case city = "city_map"
            
            var imageName: String {
                return self.rawValue
            }
            
            var displayName: String {
                switch self {
                case .jungle:
                    return "정글"
                }
            }
        }
    }
    
    // MARK: - Game Balance
    struct Balance {
        static let scorePerKill: Int = 1
        static let zombieNormalSpawnRate: Int = 60  // 60%
        static let zombieFastSpawnRate: Int = 25    // 25%
        static let zombieStrongSpawnRate: Int = 15  // 15%
    }
}
