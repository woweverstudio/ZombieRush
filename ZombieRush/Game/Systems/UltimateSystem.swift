//
//  UltimateSystem.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SpriteKit

// MARK: - Ultimate Skill Protocol
protocol UltimateSkill {
    var name: String { get }
    var description: String { get }
    var imageName: String { get }
    var isReady: Bool { get }

    // 콜백 이벤트들
    var onZombieKilled: ((Zombie) -> Void)? { get set }

    func execute(at position: CGPoint, in scene: SKScene)
}

// MARK: - Nuclear Attack Implementation
class NuclearAttackSkill: UltimateSkill {

    // MARK: - Deinit for Memory Management
    deinit {
        // 콜백 클로저 정리
        onZombieKilled = nil
    }
    
    let name = "Nuclear Attack"
    let description = "Destroys all enemies in a massive explosion"
    let imageName = "ultimate_nuclear"

    var isReady: Bool {
        // 궁극기는 게이지 시스템으로 제어되므로 항상 true
        return true
    }

    // MARK: - Dependencies
    weak var scene: SKScene?
    weak var cameraSystem: CameraSystem?
    weak var toastMessageManager: ToastMessageManager?
    weak var zombieSpawnSystem: ZombieSpawnSystem?

    // MARK: - Callbacks
    var onZombieKilled: ((Zombie) -> Void)?

    func execute(at position: CGPoint, in scene: SKScene) {
        // 토스트 메시지 표시
        let message = TextConstants.Ultimate.nuclearActivated
        toastMessageManager?.showToastMessage(message, duration: 2.0)

        // 줌아웃 시작
        cameraSystem?.startUltimateZoomOut()

        // 1초 뒤에 폭발
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.performNuclearExplosion(at: position)
        }
    }

    private func performNuclearExplosion(at position: CGPoint) {
        guard let scene = scene else {
            return
        }

        // 핵폭발 효과 생성
        Nuclear.createNuclearExplosion(at: position, in: scene)

        // 모든 좀비 즉사 처리 (반경 900)
        destroyAllZombiesInRadius(at: position, radius: 900)

        // 음향 효과
        Nuclear.playNuclearSound(in: scene)

        // 카메라 shake 효과
        cameraSystem?.shakeCamera()

        // 줌인 시작
        cameraSystem?.startUltimateZoomIn()
    }

    private func destroyAllZombiesInRadius(at center: CGPoint, radius: CGFloat) {
        guard let scene = scene, let zombieSpawnSystem = zombieSpawnSystem else {
            return
        }

        // 반경의 제곱을 미리 계산 (sqrt 연산 비용 절약)
        let radiusSquared = radius * radius

        // ZombieSpawnSystem의 zombies 배열을 직접 사용하여 좀비 처리
        for zombie in zombieSpawnSystem.getZombies() {
            // 이미 죽은 좀비는 스킵
            if zombie.getHealth() <= 0 {
                continue
            }

            // 거리 계산 최적화 (제곱 비교로 sqrt 연산 제거)
            let dx = zombie.position.x - center.x
            let dy = zombie.position.y - center.y
            let distanceSquared = dx * dx + dy * dy

            // 반경 내에 있는 경우에만 처리
            if distanceSquared <= radiusSquared {
                // 좀비 처리 로직을 인라인으로 처리 (메서드 호출 오버헤드 제거)
                if scene.parent != nil {
                    Nuclear.createZombieExplosionEffect(at: zombie.position, in: scene)
                }

                let isDead = zombie.takeDamage(999)

                if isDead {
                    zombieSpawnSystem.removeZombie(zombie)
                    zombieSpawnSystem.updateZombies()
                    onZombieKilled?(zombie)
                }
            }
        }
    }
}

