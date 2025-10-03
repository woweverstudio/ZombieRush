//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

extension SettingsView {
    static let settingsTitle = NSLocalizedString("설정", tableName: "Settings", comment: "Settings title")
    static let soundEffectsLabel = NSLocalizedString("효과음", tableName: "Settings", comment: "Sound effects label")
    static let backgroundMusicLabel = NSLocalizedString("배경음악", tableName: "Settings", comment: "Background music label")
    static let vibrationLabel = NSLocalizedString("진동", tableName: "Settings", comment: "Vibration label")
}

struct SettingsView: View {
    @Environment(AppRouter.self) var router
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()
            
            VStack(spacing: 20) {
                // 상단 영역 - 제목과 뒤로가기 버튼
                Header(
                    title: SettingsView.settingsTitle,
                    onBack: {
                        router.quitToMain()
                    }
                )
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    SettingRow(
                        title: SettingsView.backgroundMusicLabel,
                        icon: "music.note",
                        initialValue: AudioManager.shared.isBackgroundMusicEnabled
                    ) { newValue in
                        AudioManager.shared.isBackgroundMusicEnabled = newValue
                    }
                    .padding(.bottom, 10)

                    SettingRow(
                        title: SettingsView.soundEffectsLabel,
                        icon: "speaker.wave.2.fill",
                        initialValue: AudioManager.shared.isSoundEffectsEnabled
                    )
                    { newValue in
                        AudioManager.shared.isSoundEffectsEnabled = newValue
                    }
                    .padding(.bottom, 10)

                    SettingRow(
                        title: SettingsView.vibrationLabel,
                        icon: "iphone.radiowaves.left.and.right",
                        initialValue: HapticManager.shared.isHapticEnabled
                    )
                    { newValue in
                        HapticManager.shared.isHapticEnabled = newValue
                    }

                    
                }
                
                // 현재 버전 표시
                Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0")")
                    .font(.system(size: 14))
                    .foregroundColor(Color.dsTextSecondary)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
            }
            .padding()
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
                .font(.system(size: 16))
                .foregroundColor(Color.dsTextPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
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
