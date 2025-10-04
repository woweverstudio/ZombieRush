//
//  AudioManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import Foundation
import AVFoundation

final class AudioManager: NSObject {
    // 싱글턴
    static let shared = AudioManager()
    
    // MARK: - Properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var buttonSoundPlayer: AVAudioPlayer?   // 버튼 사운드를 미리 로드해서 재사용
    private var currentMusicName: String?
    private var currentMusicType: MusicType = .mainMenu
    
    var isBackgroundMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBackgroundMusicEnabled, forKey: "isBackgroundMusicEnabled")
            if isBackgroundMusicEnabled {
                playBackgroundMusic(type: currentMusicType)
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    var isSoundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: "isSoundEffectsEnabled")
        }
    }

    var masterVolume: Float {
        didSet {
            UserDefaults.standard.set(masterVolume, forKey: "masterVolume")
            // 현재 재생 중인 배경음악 볼륨 업데이트
            if let player = backgroundMusicPlayer {
                player.volume = ResourceConstants.Audio.BackgroundMusic.volume * masterVolume
            }
            // 버튼 사운드 볼륨 업데이트
            if let player = buttonSoundPlayer {
                player.volume = masterVolume
            }
        }
    }
    
    // MARK: - Music Types
    enum MusicType {
        case mainMenu, game, fallback, market, story
    }
    
    // MARK: - Initialization
    override init() {
        self.isBackgroundMusicEnabled = UserDefaults.standard.bool(forKey: "isBackgroundMusicEnabled", defaultValue: true)
        self.isSoundEffectsEnabled = UserDefaults.standard.bool(forKey: "isSoundEffectsEnabled", defaultValue: true)
        self.masterVolume = UserDefaults.standard.object(forKey: "masterVolume") as? Float ?? 0.3

        super.init()

        setupAudioSession()
        setupNotifications()
        preloadButtonSound()   // 버튼 사운드 미리 로드
        
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
    func playStoryMusic() { playBackgroundMusic(type: .story) }
    func playMainMenuMusic() { playBackgroundMusic(type: .mainMenu) }
    func playGameMusic() { playBackgroundMusic(type: .game) }
    func playMarketMusic() { playBackgroundMusic(type: .market) }
    
    func playBackgroundMusic(type: MusicType = .fallback) {
        guard isBackgroundMusicEnabled else { return }
        
        let musicName = selectMusicFile(for: type)
        
        // 같은 음악이 이미 재생 중이면 스킵
        if currentMusicName == musicName && backgroundMusicPlayer?.isPlaying == true {
            return
        }
        
        playMusic(named: musicName, type: type)
    }
    
    private func selectMusicFile(for type: MusicType) -> String {
        switch type {
        case .story:
            return ResourceConstants.Audio.BackgroundMusic.mainMenuTrack
            
        case .mainMenu:
            let today = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: today)
            return (day % 2 == 0)
                ? ResourceConstants.Audio.BackgroundMusic.mainMenuTrack
                : ResourceConstants.Audio.BackgroundMusic.mainMenuTrack2
            
        case .market:
            return ResourceConstants.Audio.BackgroundMusic.marketTrack
        case .game:
            return ResourceConstants.Audio.BackgroundMusic.gameTrack
        case .fallback:
            return ResourceConstants.Audio.BackgroundMusic.mainMenuTrack
        }
    }
    
    private func playMusic(named musicName: String, type: MusicType) {
        stopBackgroundMusic()
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: ResourceConstants.Audio.BackgroundMusic.fileExtension) else {
            if type != .fallback { playBackgroundMusic(type: .fallback) }
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = ResourceConstants.Audio.BackgroundMusic.volume * masterVolume
            player.prepareToPlay()
            
            self.backgroundMusicPlayer = player
            self.currentMusicName = musicName
            self.currentMusicType = type
            player.play()
        } catch {
            if type != .fallback {
                playBackgroundMusic(type: .fallback)
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentMusicName = nil
    }
    
    // MARK: - Button Sound (Preload + Play)
    private func preloadButtonSound() {
        guard let url = Bundle.main.url(forResource: "button", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = masterVolume
            player.prepareToPlay()
            self.buttonSoundPlayer = player
        } catch {
            // 로드 실패 시 무시
        }
    }
    
    func playButtonSound() {
        guard isSoundEffectsEnabled else { return }
        guard let player = buttonSoundPlayer else {
            // 버튼 사운드가 로드되지 않은 경우 재로드 시도
            preloadButtonSound()
            return
        }

        if player.isPlaying {
            player.stop()
        }
        player.currentTime = 0
        // 실시간 볼륨 적용
        player.volume = masterVolume
        player.play()
    }

    /// 일반 효과음 재생 (마스터 볼륨 적용)
    func playSoundEffect(_ soundName: String) {
        guard isSoundEffectsEnabled else { return }

        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("❌ 효과음 파일을 찾을 수 없음: \(soundName)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = masterVolume
            player.play()
        } catch {
            print("❌ 효과음 재생 실패: \(soundName), 에러: \(error.localizedDescription)")
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
