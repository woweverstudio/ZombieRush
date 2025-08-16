//
//  ContentView.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showGameView = false
    @State private var showSettingsView = false
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            // 배경 이미지
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                // 상단 영역
                HStack {
                    Spacer()
                    
                    // 설정 버튼 (우측 상단)
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 50) // 상단에서 충분한 간격
                .padding(.trailing, 30) // 우측에서 충분한 간격
                
                Spacer()
                
                // 중앙 영역 - 게임시작 버튼만
                VStack(spacing: 20) {
                    // 게임시작 버튼
                    Button(action: {
                        showGameView = true
                    }) {
                        Text("Game Start")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                            .frame(width: 220, height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black, radius: 12, x: 0, y: 6)
                            .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40) // 좌우에서 충분한 간격
                
                Spacer()
                
                // 하단 여백
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 50)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGameView) {
            GameView()
        }
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView()
        }
        .onAppear {
            // 앱 시작 시 백그라운드 뮤직 재생
            if audioManager.isBackgroundMusicEnabled {
                audioManager.playBackgroundMusic()
            }
        }
    }
}

#Preview {
    ContentView()
}
