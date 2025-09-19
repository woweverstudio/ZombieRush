//
 //  ServiceUnavailableView.swift
 //  ZombieRush
 //
 //  Created by Service Unavailable Screen
 //

import SwiftUI

struct ServiceUnavailableView: View {
    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 40) {
                Spacer()

                // 타이틀
                Text(TextConstants.ServiceUnavailable.title)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // 메시지
                Text(TextConstants.ServiceUnavailable.message)
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
