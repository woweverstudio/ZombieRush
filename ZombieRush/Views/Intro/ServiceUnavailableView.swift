//
 //  ServiceUnavailableView.swift
 //  ZombieRush
 //
 //  Created by Service Unavailable Screen
 //

import SwiftUI

extension ServiceUnavailableView {
    static let serviceUnavailableTitle = NSLocalizedString("intro_service_unavailable_title", tableName: "View", comment: "Service unavailable title")
    static let serviceUnavailableMessage = NSLocalizedString("intro_service_unavailable_message", tableName: "View", comment: "Service unavailable message")
}

struct ServiceUnavailableView: View {
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: UIConstants.Spacing.x32) {
                Spacer()

                // 타이틀
                Text(verbatim: ServiceUnavailableView.serviceUnavailableTitle)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .multilineTextAlignment(.center)

                // 메시지
                Text(verbatim: ServiceUnavailableView.serviceUnavailableMessage)
                    .font(.system(size: 18, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UIConstants.Spacing.x8)

                Spacer()
            }
            .pagePadding()
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    ServiceUnavailableView()
}
