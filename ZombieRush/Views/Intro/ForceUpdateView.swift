//
//  ForceUpdateView.swift
//  ZombieRush
//
//  Created by Force Update Screen
//

import SwiftUI
import UIKit

extension ForceUpdateView {
    static let newVersionMessage = NSLocalizedString("intro_new_version_available_message", tableName: "View", comment: "New version available message")
    static let goToAppStoreButton = NSLocalizedString("intro_go_to_app_store_button", tableName: "View", comment: "Go to App Store button")
}

struct ForceUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var versionManager = VersionManager.shared

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 40) {
                Spacer()

                // 타이틀
                Text(verbatim: ForceUpdateView.newVersionMessage)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .multilineTextAlignment(.center)

                // 앱스토어 이동 버튼
                PrimaryButton(title: ForceUpdateView.goToAppStoreButton, style: .cyan, fullWidth: true) {
                    openAppStore()
                }

                Spacer()
            }
            .padding(.horizontal, 40)
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
