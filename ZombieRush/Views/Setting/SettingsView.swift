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
            Background()
            
            VStack {
                // 상단 영역 - 제목과 뒤로가기 버튼
                Header(
                    title: TextConstants.Settings.title,
                    onBack: {
                        router.quitToMain()
                    }
                )
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    
                    // 사운드 설정
                    SettingRow(
                        title: TextConstants.Settings.soundEffects,
                        icon: "speaker.wave.2.fill",
                        isOn: $bindableAudioManager.isSoundEffectsEnabled
                    )
                    .padding(.bottom, 10)

                    SettingRow(
                        title: TextConstants.Settings.backgroundMusic,
                        icon: "music.note",
                        isOn: $bindableAudioManager.isBackgroundMusicEnabled
                    )
                    .padding(.bottom, 10)

                    SettingRow(
                        title: TextConstants.Settings.vibration,
                        icon: "iphone.radiowaves.left.and.right",
                        isOn: $bindableHapticManager.isHapticEnabled
                    )
                    
                }
            }
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
                .foregroundColor(Color.dsTextPrimary)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.dsTextPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.cyan))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.dsOverlay)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
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
