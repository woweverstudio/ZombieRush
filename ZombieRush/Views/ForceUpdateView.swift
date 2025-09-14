//
//  ForceUpdateView.swift
//  ZombieRush
//
//  Created by Force Update Screen
//

import SwiftUI
import UIKit

struct ForceUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var versionManager = VersionManager.shared

    var body: some View {
        ZStack {
            // 배경
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // 아이콘/이미지
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)

                // 타이틀
                Text("앱 업데이트 필요")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                // 설명
                Text("새 버전이 출시되었습니다.\n최신 버전으로 업데이트해주세요.")
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Spacer()

                // 업데이트 버튼
                Button(action: {
                    openAppStore()
                }) {
                    Text("앱스토어로 이동")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.cyan)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }

                Spacer()
                    .frame(height: 50)
            }
        }
        .statusBar(hidden: true)
        // iOS 15+에서 제스처로 닫는 것을 막음
        .interactiveDismissDisabled(true)
        // dismiss 방지
        .onDisappear {
            // 업데이트가 필요한 경우 다시 표시
            if versionManager.shouldForceUpdate {
                DispatchQueue.main.async {
                    // 다시 표시하는 로직은 필요시 구현
                }
            }
        }
    }

    /// App Store로 이동
    private func openAppStore() {
        let appStoreURL = "https://apps.apple.com/app/id\(SupabaseConfig.appStoreId)"

        if let url = URL(string: appStoreURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            // App Store 앱이 없는 경우 웹으로 이동
            let webURL = "https://apps.apple.com/app/id\(SupabaseConfig.appStoreId)"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}

#Preview {
    ForceUpdateView()
}
