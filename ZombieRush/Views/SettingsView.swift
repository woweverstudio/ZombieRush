//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) var router
    @Environment(AudioManager.self) var audioManager
    @Environment(HapticManager.self) var hapticManager
    
    var body: some View {
        // @Bindable을 body 내부에서 생성
        @Bindable var bindableAudioManager = audioManager
        @Bindable var bindableHapticManager = hapticManager
        
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground(opacity: 0.6)
            
            VStack {
                // 상단 영역 - 제목과 뒤로가기 버튼
                headerSection
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    
                    // 사운드 설정
                    SettingRow(
                        title: NSLocalizedString("SETTINGS_SOUND_EFFECTS", comment: "Sound effects setting"),
                        icon: "speaker.wave.2.fill",
                        isOn: $bindableAudioManager.isSoundEffectsEnabled
                    )
                    .padding(.bottom, 10)

                    SettingRow(
                        title: NSLocalizedString("SETTINGS_BACKGROUND_MUSIC", comment: "Background music setting"),
                        icon: "music.note",
                        isOn: $bindableAudioManager.isBackgroundMusicEnabled
                    )
                    .padding(.bottom, 10)

                    SettingRow(
                        title: NSLocalizedString("SETTINGS_VIBRATION", comment: "Vibration setting"),
                        icon: "iphone.radiowaves.left.and.right",
                        isOn: $bindableHapticManager.isHapticEnabled
                    )
                    
                }
            }
            .padding()
        }
    }
    
    var headerSection: some View {
        HStack {
            // 뒤로가기 버튼
            BackButton(style: .cyan) { router.goBack() }
            
            Spacer()
            
            // 설정 타이틀
            SectionTitle(NSLocalizedString("SETTINGS_TITLE", comment: "Settings screen title"), size: 28)
            
            Spacer()
            
            BackButton(style: .cyan) { }
            .opacity(0)
        }
    }
}

struct SettingRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.0, green: 0.8, blue: 1.0)))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SettingsView()
        .environment(AppRouter())
        .environment(AudioManager.shared)
        .environment(HapticManager.shared)
        .preferredColorScheme(.dark)
}
