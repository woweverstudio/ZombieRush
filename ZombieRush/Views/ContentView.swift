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
            // 사이버펑크 배경 이미지
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 어두운 오버레이로 텍스트 가독성 향상
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                // 상단 영역
                HStack {
                    Spacer()
                    
                    // 네온 설정 버튼 (우측 상단)
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 1.0))
                            .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0), radius: 8, x: 0, y: 0)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .overlay(
                                        Circle()
                                            .stroke(Color(red: 1.0, green: 0.0, blue: 1.0), lineWidth: 2)
                                    )
                            )
                            .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.4), radius: 15, x: 0, y: 0)
                    }
                }
                .padding(.top, 50) // 상단에서 충분한 간격
                .padding(.trailing, 30) // 우측에서 충분한 간격
                
                Spacer()
                
                // 게임 타이틀
                VStack(spacing: 10) {
                    Text("ATTACK ON")
                        .font(.system(size: 32, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 1.0))
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0), radius: 15, x: 0, y: 0)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.5), radius: 30, x: 0, y: 0)
                    
                    Text("SQUARE")
                        .font(.system(size: 48, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 20, x: 0, y: 0)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.5), radius: 40, x: 0, y: 0)
                }
                .padding(.bottom, 40)
                
                // 중앙 영역 - 게임시작 버튼
                VStack(spacing: 20) {
                    // 네온 게임시작 버튼
                    Button(action: {
                        showGameView = true
                    }) {
                        Text("GAME START")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                            .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 10, x: 0, y: 0)
                            .frame(width: 240, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.0, green: 0.8, blue: 1.0), lineWidth: 2)
                                            .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0), radius: 15, x: 0, y: 0)
                                    )
                            )
                            .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.5), radius: 20, x: 0, y: 0)
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
