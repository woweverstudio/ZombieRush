//
//  SettingsView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
    var body: some View {
        ZStack {
            // 배경 이미지 (반투명 오버레이)
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 반투명 어두운 오버레이
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 영역 - 제목과 뒤로가기 버튼 (고정)
                HStack {
                    // 뒤로가기 버튼 (더 크고 명확하게)
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                            Text("뒤로")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // 설정 타이틀
                    Text("SETTINGS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 10, x: 0, y: 0)
                    
                    Spacer()
                    
                    // 빈 공간으로 균형 맞추기
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.clear)
                        .frame(width: 100, height: 44)
                }
                .padding(.top, 50) // 상단에서 충분한 간격
                .padding(.horizontal, 30) // 좌우에서 충분한 간격
                .padding(.bottom, 20)
                
                // 설정 옵션들 (스크롤 가능)
                ScrollView {
                    VStack(spacing: 20) {
                        // 사운드 설정
                        SettingRow(
                            title: "효과음",
                            icon: "speaker.wave.2.fill",
                            isOn: $soundEnabled
                        )
                        
                        // 음악 설정 (AudioManager와 연결)
                        SettingRow(
                            title: "배경음악",
                            icon: "music.note",
                            isOn: $audioManager.isBackgroundMusicEnabled
                        )
                        
                        // 진동 설정
                        SettingRow(
                            title: "진동",
                            icon: "iphone.radiowaves.left.and.right",
                            isOn: $vibrationEnabled
                        )
                        
                        // 하단 여백
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 30)
                    }
                    .padding(.horizontal, 40) // 좌우에서 충분한 간격
                }
                
                // 하단 영역 (고정)
                HStack(spacing: 15) {
                    Text("version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    Text("© 2025 woweverstudio")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 50) // 하단에서 충분한 간격
                .padding(.horizontal, 30) // 좌우에서 충분한 간격
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
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
