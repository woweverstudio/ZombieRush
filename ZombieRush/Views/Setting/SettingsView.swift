//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

extension SettingsView {
    static let settingsTitle = NSLocalizedString("screen_title_settings", tableName: "View", comment: "Settings screen title")
    static let soundEffectsLabel = NSLocalizedString("settings_sound_effects_label", tableName: "View", comment: "Settings sound effects label")
    static let backgroundMusicLabel = NSLocalizedString("settings_background_music_label", tableName: "View", comment: "Settings background music label")
    static let vibrationLabel = NSLocalizedString("settings_haptic_feedback_label", tableName: "View", comment: "Settings haptic feedback label")
    static let volumeLabel = NSLocalizedString("settings_volume_label", tableName: "View", comment: "Settings volume label")
    static let versionPrefix = NSLocalizedString("settings_version_prefix", tableName: "View", comment: "Settings version prefix")
}

struct SettingsView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()
            
            VStack(spacing: 20) {
                // 상단 영역 - 제목과 뒤로가기 버튼
                Header(
                    title: SettingsView.settingsTitle,
                    onBack: {
                        router.goBack()
                    }
                )
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    SettingRow(
                        title: SettingsView.backgroundMusicLabel,
                        icon: "music.note",
                        initialValue: AudioManager.shared.isBackgroundMusicEnabled
                    ) { newValue in
                        AudioManager.shared.setBackgroundMusicEnabled(newValue)
                    }
                    .padding(.bottom, 10)

                    SettingRow(
                        title: SettingsView.soundEffectsLabel,
                        icon: "speaker.wave.2.fill",
                        initialValue: AudioManager.shared.isSoundEffectsEnabled
                    )
                    { newValue in
                        AudioManager.shared.setSoundEffectsEnabled(newValue)
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
                    .padding(.bottom, 10)

                    // 볼륨 조절 슬라이더
                    VolumeRow(
                        title: SettingsView.volumeLabel,
                        icon: "speaker.wave.3.fill",
                        initialValue: AudioManager.shared.masterVolume
                    ) { newValue in
                        AudioManager.shared.setMasterVolume(newValue)
                    }

                }
                
                // 현재 버전 표시
                Text("\(SettingsView.versionPrefix)\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0")")
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

struct VolumeRow: View {
    let title: String
    let icon: String
    @State private var volume: Float
    let onVolumeChange: (Float) -> Void

    init(title: String, icon: String, initialValue: Float, onVolumeChange: @escaping (Float) -> Void) {
        self.title = title
        self.icon = icon
        _volume = State(initialValue: initialValue)
        self.onVolumeChange = onVolumeChange
    }

    var body: some View {
        VStack(spacing: 8) {
            // 제목과 아이콘
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color.dsTextPrimary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.dsTextPrimary)

                Spacer()

                // 현재 볼륨 값 표시
                Text("\(Int(volume * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.cyan)
                    .frame(width: 45, alignment: .trailing)
            }

            // 볼륨 슬라이더
            Slider(value: $volume, in: 0...1, step: 0.1)
                .tint(Color.cyan)
                .onChange(of: volume) { oldValue, newValue in
                    onVolumeChange(newValue)
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
