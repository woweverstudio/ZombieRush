//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var router = AppRouter.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground(opacity: 0.6)        .ignoresSafeArea()
            
            VStack {
                // 상단 영역 - 제목과 뒤로가기 버튼
                HStack {
                    // 뒤로가기 버튼
                    BackButton(style: .cyan) {
                        router.goBack()
                    }
                    
                    Spacer()
                    
                    // 설정 타이틀
                    SectionTitle("SETTINGS", size: 28)
                    
                    Spacer()
                    
                    BackButton(style: .cyan) {
                        
                    }
                    .opacity(0)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    
                    // 사운드 설정
                    SettingRow(
                        title: "효과음",
                        icon: "speaker.wave.2.fill",
                        isOn: $audioManager.isSoundEffectsEnabled
                    )
                    .padding(.bottom, 10)
                    
                    SettingRow(
                        title: "배경음악",
                        icon: "music.note",
                        isOn: $audioManager.isBackgroundMusicEnabled
                    )
                    .padding(.bottom, 10)
                    
                    SettingRow(
                        title: "진동",
                        icon: "iphone.radiowaves.left.and.right",
                        isOn: $hapticManager.isHapticEnabled
                    )
                    
                }
            }
            .padding()
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
}
