//
//  AudioManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var buttonSoundPlayer: AVAudioPlayer?
    private var currentMusicName: String?
    private var currentMusicType: MusicType = .mainMenu
    
    @Published var isBackgroundMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBackgroundMusicEnabled, forKey: "isBackgroundMusicEnabled")
            if isBackgroundMusicEnabled {
                playBackgroundMusic(type: currentMusicType)
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @Published var isSoundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: "isSoundEffectsEnabled")
        }
    }
    
    // MARK: - Music Types
    enum MusicType {
        case mainMenu, game, fallback
    }
    
    // MARK: - Initialization
    override private init() {
        self.isBackgroundMusicEnabled = UserDefaults.standard.bool(forKey: "isBackgroundMusicEnabled", defaultValue: true)
        self.isSoundEffectsEnabled = UserDefaults.standard.bool(forKey: "isSoundEffectsEnabled", defaultValue: true)
        
        super.init()
        
        setupAudioSession()
        setupNotifications()
        
        if isBackgroundMusicEnabled {
            playBackgroundMusic()
        }
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            try session.setActive(true)
        } catch {
            // 오디오 세션 설정 실패 시 무시
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification, object: nil
        )
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .ended && isBackgroundMusicEnabled && backgroundMusicPlayer?.isPlaying != true {
            backgroundMusicPlayer?.play()
        }
    }
    
    // MARK: - Background Music
    func playMainMenuMusic() { playBackgroundMusic(type: .mainMenu) }
    func playGameMusic() { playBackgroundMusic(type: .game) }
    
    func playBackgroundMusic(type: MusicType = .fallback) {
        guard isBackgroundMusicEnabled else { return }
        
        let musicName = selectMusicFile(for: type)
        
        // 같은 음악이 재생 중이면 스킵
        if currentMusicName == musicName && backgroundMusicPlayer?.isPlaying == true {
            return
        }
        
        playMusic(named: musicName, type: type)
    }
    
    private func selectMusicFile(for type: MusicType) -> String {
        switch type {
        case .mainMenu:
            return GameConstants.Audio.BackgroundMusic.mainMenuTrack
        case .game:
            return GameConstants.Audio.BackgroundMusic.gameTrack
        case .fallback:
            // 메인 메뉴 음악을 fallback으로 사용
            return GameConstants.Audio.BackgroundMusic.mainMenuTrack
        }
    }
    
    private func playMusic(named musicName: String, type: MusicType) {
        stopBackgroundMusic()
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: GameConstants.Audio.BackgroundMusic.fileExtension) else {
            if type != .fallback { playBackgroundMusic(type: .fallback) }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = GameConstants.Audio.BackgroundMusic.volume
                player.prepareToPlay()
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.backgroundMusicPlayer = player
                    self.currentMusicName = musicName
                    self.currentMusicType = type
                    player.play()
                }
            } catch {
                if type != .fallback {
                    DispatchQueue.main.async { [weak self] in
                        self?.playBackgroundMusic(type: .fallback)
                    }
                }
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentMusicName = nil
    }
    
    // MARK: - Sound Effects (SwiftUI용)
    func playButtonSound() {
        guard isSoundEffectsEnabled else { return }
        guard let url = Bundle.main.url(forResource: "button", withExtension: "mp3") else { return }
        
        // 기존 버튼 사운드가 재생 중이면 정지
        buttonSoundPlayer?.stop()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.8
                player.prepareToPlay()
                
                DispatchQueue.main.async {
                    self?.buttonSoundPlayer = player
                    player.play()
                }
            } catch {
                // 재생 실패 시 무시
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
        backgroundMusicPlayer?.stop()
        buttonSoundPlayer?.stop()
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