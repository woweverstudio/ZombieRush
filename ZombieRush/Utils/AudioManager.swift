//
//  AudioManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import AVFoundation
import SwiftUI

// MARK: - Audio Resources
extension AudioManager {
    enum AudioResources {

        // MARK: - Background Music
        enum BackgroundMusic {
            static let mainMenuTrack = "main_background"
            static let mainMenuTrack2 = "main_background2"
            static let gameTrack = "game_background"
            static let marketTrack = "market_background"
            static let fileExtension = "mp3"
            static let volume: Float = 0.2
        }

        // MARK: - Sound Effects
        enum SoundEffects {
            static let shoot = "shoot.wav"
            static let shotgun = "shotgun.wav"
            static let reload = "reload.wav"
            static let button = "button.mp3"
            static let item = "item.wav"
            static let hit = "hit.wav"
        }
    }
}

final class AudioManager {
    // 싱글턴
    static let shared = AudioManager()

    // MARK: - Properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var buttonSoundPlayer: AVAudioPlayer?
    private var currentMusicName: String?
    private var currentMusicType: MusicType = .mainMenu

    private(set) var isBackgroundMusicEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isBackgroundMusicEnabled, forKey: "isBackgroundMusicEnabled")
            if isBackgroundMusicEnabled {
                playBackgroundMusic(type: currentMusicType)
            } else {
                stopBackgroundMusic()
            }
        }
    }

    private(set) var isSoundEffectsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: "isSoundEffectsEnabled")
        }
    }

    private(set) var masterVolume: Float = 0.3 {
        didSet {
            UserDefaults.standard.set(masterVolume, forKey: "masterVolume")
            // 현재 재생 중인 배경음악 볼륨 업데이트
            if let player = backgroundMusicPlayer {
                player.volume = AudioResources.BackgroundMusic.volume * masterVolume
            }
            // 버튼 사운드 플레이어 볼륨 업데이트
            buttonSoundPlayer?.volume = masterVolume
        }
    }

    // MARK: - Settings Methods (외부 설정 변경용)
    func setBackgroundMusicEnabled(_ enabled: Bool) {
        self.isBackgroundMusicEnabled = enabled
    }

    func setSoundEffectsEnabled(_ enabled: Bool) {
        self.isSoundEffectsEnabled = enabled
    }

    func setMasterVolume(_ volume: Float) {
        self.masterVolume = volume
    }

    // MARK: - Music Types
    enum MusicType {
        case mainMenu, game, fallback, market, story
    }
    
    // MARK: - Initialization
    private init() {
        // AudioManager는 initializeAudioManager()를 통해 초기화되어야 함
    }

    // MARK: - Complete Initialization (Processor에서 호출)
    func initializeAudioManager() {
        // UserDefaults에서 설정값 로드 (기본값 덮어쓰기)
        self.isBackgroundMusicEnabled = UserDefaults.standard.bool(forKey: "isBackgroundMusicEnabled", defaultValue: true)
        self.isSoundEffectsEnabled = UserDefaults.standard.bool(forKey: "isSoundEffectsEnabled", defaultValue: true)
        self.masterVolume = UserDefaults.standard.object(forKey: "masterVolume") as? Float ?? 0.3

        // 오디오 세션 설정
        setupAudioSession()

        // 노티피케이션 옵저버 설정
        setupNotifications()

        // 사운드 캐싱
        preloadButtonSound()

        // 배경음악 시작 (활성화된 경우)
        if isBackgroundMusicEnabled {
            playBackgroundMusic()
        }
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP])

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
            return AudioResources.BackgroundMusic.mainMenuTrack

        case .mainMenu:
            let today = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: today)
            return (day % 2 == 0)
                ? AudioResources.BackgroundMusic.mainMenuTrack
                : AudioResources.BackgroundMusic.mainMenuTrack2

        case .market:
            return AudioResources.BackgroundMusic.marketTrack
        case .game:
            return AudioResources.BackgroundMusic.gameTrack
        case .fallback:
            return AudioResources.BackgroundMusic.mainMenuTrack
        }
    }
    
    private func playMusic(named musicName: String, type: MusicType) {
        stopBackgroundMusic()
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: AudioResources.BackgroundMusic.fileExtension) else {
            if type != .fallback { playBackgroundMusic(type: .fallback) }
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = AudioResources.BackgroundMusic.volume * masterVolume
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
        guard buttonSoundPlayer == nil else { return } // 이미 로드됨

        guard let url = Bundle.main.url(forResource: AudioResources.SoundEffects.button, withExtension: nil) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = masterVolume
            player.prepareToPlay()
            self.buttonSoundPlayer = player
        } catch {
            // 로드 실패 시 무시 (다음에 재시도)
        }
    }
    
    func playButtonSound() {
        guard isSoundEffectsEnabled else { return }

        DispatchQueue.main.async {
            if let player = self.buttonSoundPlayer {
                // 캐시된 플레이어 사용
                self.playWithPlayer(player)
            } else {
                // 캐시 없으면 즉시 생성 및 재생
                self.createAndPlayImmediately()
            }
        }
    }

    private func playWithPlayer(_ player: AVAudioPlayer) {
        if player.isPlaying {
            player.stop()
        }
        player.currentTime = 0
        player.volume = masterVolume
        player.play()
    }

    private func createAndPlayImmediately() {
        guard let url = Bundle.main.url(forResource: AudioResources.SoundEffects.button, withExtension: nil) else {
            return // 파일이 없으면 무음
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = masterVolume
            player.prepareToPlay()
            player.play()

            // 성공 시 다음 사용을 위해 캐시에 저장
            self.buttonSoundPlayer = player

        } catch {
            // 생성 실패 시 무음 (fallback)
        }
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
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
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
