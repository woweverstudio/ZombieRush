//
//  HapticManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import UIKit

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @Published var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled")
        }
    }
    
    // MARK: - Haptic Generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Initialization
    private init() {
        self.isHapticEnabled = UserDefaults.standard.bool(forKey: "isHapticEnabled", defaultValue: true)
        
        // 햅틱 제너레이터 준비
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
    }
    
    // MARK: - Haptic Methods
    func playShootHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(GameConstants.Haptic.shootIntensity))
    }
    
    func playShotgunHaptic() {
        guard isHapticEnabled else { return }
        impactHeavy.impactOccurred(intensity: CGFloat(GameConstants.Haptic.shotgunIntensity))
    }
    
    func playHitHaptic() {
        guard isHapticEnabled else { return }
        impactMedium.impactOccurred(intensity: CGFloat(GameConstants.Haptic.hitIntensity))
    }
    
    func playItemHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(GameConstants.Haptic.itemIntensity))
    }
    
    func playButtonHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred(intensity: CGFloat(GameConstants.Haptic.buttonIntensity))
    }
    
    // MARK: - Generic Haptic Methods
    func playLightHaptic() {
        guard isHapticEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func playMediumHaptic() {
        guard isHapticEnabled else { return }
        impactMedium.impactOccurred()
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
