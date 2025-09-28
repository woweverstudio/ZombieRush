//
 //  ServiceUnavailableView.swift
 //  ZombieRush
 //
 //  Created by Service Unavailable Screen
 //

import SwiftUI

extension ServiceUnavailableView {
    static let serviceUnavailableTitle = NSLocalizedString("service_unavailable_title", tableName: "Intro", comment: "Service unavailable title")
    static let serviceUnavailableMessage = NSLocalizedString("service_unavailable_message", tableName: "Intro", comment: "Service unavailable message")
}

struct ServiceUnavailableView: View {
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 40) {
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
                    .lineSpacing(8)

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    ServiceUnavailableView()
}
