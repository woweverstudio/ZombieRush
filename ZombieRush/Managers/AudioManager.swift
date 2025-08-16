//
//  AudioManager.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isBackgroundMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBackgroundMusicEnabled, forKey: "isBackgroundMusicEnabled")
            if isBackgroundMusicEnabled {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    private init() {
        // UserDefaults에서 설정값 불러오기
        self.isBackgroundMusicEnabled = UserDefaults.standard.bool(forKey: "isBackgroundMusicEnabled")
        
        // 기본값이 설정되지 않은 경우 true로 설정
        if UserDefaults.standard.object(forKey: "isBackgroundMusicEnabled") == nil {
            self.isBackgroundMusicEnabled = true
            UserDefaults.standard.set(true, forKey: "isBackgroundMusicEnabled")
        }
        
        setupAudioSession()
        if isBackgroundMusicEnabled {
            playBackgroundMusic()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        guard isBackgroundMusicEnabled else { return }
        
        // 이미 재생 중이면 중복 재생 방지
        if backgroundMusicPlayer?.isPlaying == true { return }
        
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("background.mp3 파일을 찾을 수 없습니다")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // 무한 반복
            backgroundMusicPlayer?.volume = 0.7
            backgroundMusicPlayer?.play()
        } catch {
            print("백그라운드 뮤직 재생 실패: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        if isBackgroundMusicEnabled {
            backgroundMusicPlayer?.play()
        }
    }
}
