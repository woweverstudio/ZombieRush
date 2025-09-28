//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) var router
    
    var body: some View {
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
                    SettingRow(
                        title: TextConstants.Settings.backgroundMusic,
                        icon: "music.note",
                        initialValue: AudioManager.shared.isBackgroundMusicEnabled
                    ) { newValue in
                        AudioManager.shared.isBackgroundMusicEnabled = newValue
                    }
                    .padding(.bottom, 10)
                    
                    SettingRow(
                        title: TextConstants.Settings.soundEffects,
                        icon: "speaker.wave.2.fill",
                        initialValue: AudioManager.shared.isSoundEffectsEnabled
                    )
                    { newValue in
                        AudioManager.shared.isSoundEffectsEnabled = newValue
                    }
                    .padding(.bottom, 10)

                    SettingRow(
                        title: TextConstants.Settings.vibration,
                        icon: "iphone.radiowaves.left.and.right",
                        initialValue: HapticManager.shared.isHapticEnabled
                    )
                    { newValue in
                        HapticManager.shared.isHapticEnabled = newValue
                    }
                }
            }
        }
    }
}

struct SettingRow: View {
    let title: String
    let icon: String
    @State private var isOn: Bool
    let onToggle: (Bool) -> Void

    init(title: String, icon: String, initialValue: Bool, onToggle: @escaping (Bool) -> Void) {
        self.title = title
        self.icon = icon
        _isOn = State(initialValue: initialValue)
        self.onToggle = onToggle
    }

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
                .onChange(of: isOn) { oldValue, newValue in
                    onToggle(newValue)
                }
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
        .preferredColorScheme(.dark)
}
