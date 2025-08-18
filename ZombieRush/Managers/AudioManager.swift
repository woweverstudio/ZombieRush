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
    
    // MARK: - Audio Engine System
    private let audioEngine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()
    
    // MARK: - Background Music
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
    
    @Published var isSoundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: "isSoundEffectsEnabled")
        }
    }
    
    // MARK: - Sound Effect Caching
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var playerNodes: [String: [AVAudioPlayerNode]] = [:]
    
    // 사운드 파일 정보
    private let soundFiles = [
        "shoot": "wav",
        "shotgun": "wav", 
        "reload": "wav",
        "button": "mp3"
    ]
    
    override private init() {
        // 기본값 설정 (UserDefaults에 값이 없으면 true)
        let backgroundMusicDefault = UserDefaults.standard.object(forKey: "isBackgroundMusicEnabled") as? Bool ?? true
        let soundEffectsDefault = UserDefaults.standard.object(forKey: "isSoundEffectsEnabled") as? Bool ?? true
        
        // 기본값으로 초기화
        self.isBackgroundMusicEnabled = backgroundMusicDefault
        self.isSoundEffectsEnabled = soundEffectsDefault
        
        super.init()
        
        // 기본값이 설정되지 않은 경우에만 UserDefaults에 저장
        if UserDefaults.standard.object(forKey: "isBackgroundMusicEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isBackgroundMusicEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "isSoundEffectsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isSoundEffectsEnabled")
        }
        
        setupAudioSession()
        setupAudioEngine()
        preloadSoundEffects()
        
        if isBackgroundMusicEnabled {
            playBackgroundMusic()
        }
    }
    
    // MARK: - Setup Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        // 믹서 노드를 엔진에 연결
        audioEngine.attach(mixerNode)
        
        // 적절한 오디오 포맷 설정
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
        
        // 엔진 시작
        do {
            try audioEngine.start()
            print("오디오 엔진 시작 성공")
        } catch {
            print("오디오 엔진 시작 실패: \(error)")
        }
    }
    
    private func preloadSoundEffects() {
        // 백그라운드 큐에서 사운드 파일들을 미리 로드
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            for (soundName, fileExtension) in self.soundFiles {
                self.loadAudioBuffer(soundName: soundName, fileExtension: fileExtension)
            }
            
            print("모든 사운드 효과 미리 로드 완료")
        }
    }
    
    private func loadAudioBuffer(soundName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("\(soundName).\(fileExtension) 파일을 찾을 수 없습니다")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            
            guard let buffer = buffer else {
                print("\(soundName) 버퍼 생성 실패")
                return
            }
            
            try audioFile.read(into: buffer)
            audioBuffers[soundName] = buffer
            print("\(soundName) 버퍼 로드 성공 - 길이: \(buffer.frameLength), 포맷: \(buffer.format)")
            
        } catch {
            print("\(soundName) 로드 실패: \(error)")
        }
    }
    
    // MARK: - Background Music
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
    
    // MARK: - Sound Effects (High Performance)
    private func playSoundEffect(_ soundName: String, volume: Float = 1.0) {
        guard isSoundEffectsEnabled else { 
            print("사운드 이펙트가 비활성화됨")
            return 
        }
        
        guard let buffer = audioBuffers[soundName] else {
            print("\(soundName) 버퍼를 찾을 수 없습니다")
            return
        }
        
        print("사운드 재생 시도: \(soundName), 볼륨: \(volume)")
        
        // 새로운 플레이어 노드 생성 (기존 재생 중단하지 않음)
        let playerNode = AVAudioPlayerNode()
        
        // 엔진이 실행 중인지 확인
        guard audioEngine.isRunning else {
            print("오디오 엔진이 실행되지 않음")
            return
        }
        
        audioEngine.attach(playerNode)
        
        // 버퍼의 원본 포맷으로 연결 (중요!)
        audioEngine.connect(playerNode, to: mixerNode, format: buffer.format)
        
        // 플레이어 노드 배열에 추가
        if playerNodes[soundName] == nil {
            playerNodes[soundName] = []
        }
        playerNodes[soundName]?.append(playerNode)
        
        // 볼륨 설정 및 재생
        playerNode.volume = volume
        
        // 버퍼 스케줄링 및 재생
        playerNode.scheduleBuffer(buffer, completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.cleanupPlayerNode(soundName: soundName, playerNode: playerNode)
            }
        })
        
        // AVAudioPlayerNode는 start() 메서드를 사용
        playerNode.play()
    }
    
    private func stopSoundEffect(_ soundName: String) {
        playerNodes[soundName]?.forEach { playerNode in
            playerNode.stop()
            audioEngine.detach(playerNode)
        }
        playerNodes[soundName]?.removeAll()
    }
    
    private func cleanupPlayerNode(soundName: String, playerNode: AVAudioPlayerNode) {
        audioEngine.detach(playerNode)
        
        if let index = playerNodes[soundName]?.firstIndex(of: playerNode) {
            playerNodes[soundName]?.remove(at: index)
        }
    }
    
    // MARK: - Public Sound Effect Methods
    func playShootSound() {
        playSoundEffect("shoot", volume: 0.4)  // 절반으로 줄임
    }
    
    func playShotgunSound() {
        playSoundEffect("shotgun", volume: 0.45)  // 절반으로 줄임
    }
    
    func playReloadSound() {
        playSoundEffect("reload", volume: 0.35)  // 절반으로 줄임
    }
    
    func playButtonSound() {
        playSoundEffect("button", volume: 0.6)  // 그대로 유지
    }
    
    // MARK: - Cleanup
    deinit {
        audioEngine.stop()
        backgroundMusicPlayer?.stop()
    }
}
