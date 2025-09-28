//
//  HapticManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import UIKit

final class HapticManager {
    // 게임 로직에서 사용하므로 싱글턴 유지
    static let shared = HapticManager()
    
    var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled")
        }
    }
    
    // MARK: - Haptic Generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Initialization
    init() {
        self.isHapticEnabled = UserDefaults.standard.bool(forKey: "isHapticEnabled", defaultValue: true)
        
        // 햅틱 제너레이터 준비
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactRigid.prepare()
        impactSoft.prepare()
        impactHeavy.prepare()
    }
    
    // MARK: - Haptic Methods
    func playShootHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(UIConstants.Haptic.shootIntensity))
    }
    
    func playShotgunHaptic() {
        guard isHapticEnabled else { return }
        impactSoft.impactOccurred(intensity: CGFloat(UIConstants.Haptic.shotgunIntensity))
    }
    
    func playHitHaptic() {
        guard isHapticEnabled else { return }
        impactRigid.impactOccurred(intensity: CGFloat(UIConstants.Haptic.hitIntensity))
    }
    
    func playItemHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(UIConstants.Haptic.itemIntensity))
    }
    
    func playButtonHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(UIConstants.Haptic.buttonIntensity))
    }
    
    func playUltimateReadyHaptic() {
        guard isHapticEnabled else { return }
        impactHeavy.prepare()

        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(i)) {
                self.impactHeavy.impactOccurred()
            }
        }
    }
    
    // MARK: - Generic Haptic Methods
    func playLightHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func playMediumHaptic() {
        guard isHapticEnabled else { return }
        impactRigid.impactOccurred()
    }
    
    func playHeavyHaptic() {
        guard isHapticEnabled else { return }
        impactHeavy.impactOccurred()
    }
}

// MARK: - UserDefaults Extension
private extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            set(defaultValue, forKey: key)
            return defaultValue
        }
        return bool(forKey: key)
    }
}
