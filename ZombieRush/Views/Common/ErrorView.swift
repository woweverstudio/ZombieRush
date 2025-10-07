//
//  ErrorView.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

extension ErrorView {
    static let errorTitle = NSLocalizedString("error_title", tableName: "Common", comment: "Error title")
    static let confirmButton = NSLocalizedString("confirm_button", tableName: "Common", comment: "Confirm button")
}

struct ErrorView: View {
    @Environment(AlertManager.self) var alertManager
    let error: SystemError

    var body: some View {
        VStack(spacing: 24) {
            // 에러 콘텐츠
            VStack(spacing: 16) {
                // 아이콘
                Image(systemName: error.icon)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.dsWarning)

                // 제목
                Text(error.title)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.dsTextPrimary)

                // 설명 텍스트
                Text(error.message)
                    .font(.system(size: 14, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.dsTextSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }

            // 버튼 영역
            VStack(spacing: 12) {
                PrimaryButton(
                    title: ErrorView.confirmButton,
                    style: .cyan,
                    width: 120,
                    height: 44
                ) {
                    alertManager.clearError()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}



#Preview {
    ErrorView(error: SystemError.serverError)
        .environment(AlertManager())
}
