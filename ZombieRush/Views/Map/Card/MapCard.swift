//
//  MapCard.swift
//  ZombieRush
//
//  Created by 김민성 on 10/10/25.
//

import SwiftUI

struct MapCard: View {
    let map: Map

    var body: some View {
        Card(style: .default) {
            VStack(spacing: UIConstants.Spacing.x16) {
                // 상단 스페이서로 높이 채우기
                Spacer()

                // 맵 이미지
                Image(map.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .opacity(map.isUnlocked ? 1.0 : 0.5)
                    .padding(.horizontal, UIConstants.Spacing.x8)

                // 타이틀
                Text(map.name)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(map.isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIConstants.Spacing.x16)

                // 진행상황 (웨이브) 게이지 바
                VStack(spacing: UIConstants.Spacing.x8) {
                    Text("진행 상황")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))

                    // 게이지 바
                    let progressPercentage = Double(map.clearedWave) / Double(20)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)

                            // 진행 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)

                    // 퍼센트와 웨이브 수 표시
                    HStack(spacing: UIConstants.Spacing.x8) {
                        Text("\(Int(progressPercentage * 100))% 완료")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))

                        Text("•")

                        Text("\(map.clearedWave)/20 웨이브")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, UIConstants.Spacing.x8)

                // 맵 설명
                VStack(spacing: UIConstants.Spacing.x4) {
                    Text("맵 설명")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))

                    Text(map.description)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, UIConstants.Spacing.x16)
                }

                // 맵 목표 (현재는 설명과 동일하게 표시)
                VStack(spacing: UIConstants.Spacing.x4) {
                    Text("맵 목표")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))

                    Text("모든 웨이브를 클리어하고 생존하라!")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.cyan.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, UIConstants.Spacing.x16)
                }

                // 해금 상태 (아래쪽에 배치)
                if !map.isUnlocked, let requirement = map.unlockRequirement {
                    Text("🔒 \(requirement.description) 필요")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsError)
                        .padding(.top, UIConstants.Spacing.x8)
                }

                // 하단 스페이서로 높이 채우기
                Spacer()
            }
            .padding(.vertical, UIConstants.Spacing.x24)
            .padding(.horizontal, UIConstants.Spacing.x16)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .opacity(map.isUnlocked ? 1.0 : 0.6)
        .contentShape(Rectangle())
        .frame(maxHeight: .infinity)
    }
}
