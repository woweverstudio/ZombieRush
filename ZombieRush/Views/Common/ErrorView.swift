//
//  ErrorView.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

extension ErrorView {
    static let errorTitle = NSLocalizedString("error_title", tableName: "Common", comment: "Error title")
    static let retryButton = NSLocalizedString("retry_button", tableName: "Common", comment: "Retry button")
    static let cancelButton = NSLocalizedString("cancel_button", tableName: "Common", comment: "Cancel button")
    static let confirmButton = NSLocalizedString("confirm_button", tableName: "Common", comment: "Confirm button")
    static let exitAppButton = NSLocalizedString("exit_app_button", tableName: "Common", comment: "Exit app button")
}

struct ErrorView: View {
    @Environment(ErrorManager.self) var errorManager

    var body: some View {
        if let error = errorManager.currentError {
            ZStack {
                // 배경 - Background 컴포넌트 사용
                Background()

                VStack(spacing: 24) {
                    // 에러 콘텐츠 - 카드 없이 직접 배치
                    VStack(spacing: 16) {
                        // 아이콘 - 단순화
                        Image(systemName: errorIcon(for: error.severity))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(errorColor(for: error.severity))

                        // 제목
                        Text(verbatim: ErrorView.errorTitle)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.dsTextPrimary)

                        // 설명 텍스트
                        Text(error.message.rawValue)
                            .font(.system(size: 14, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.dsTextSecondary)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                    }

                    // 버튼 영역 - 짧게 줄임
                    VStack(spacing: 12) {
                        switch error.severity {
                        case .retry:
                            HStack(spacing: 16) {
                                PrimaryButton(
                                    title: ErrorView.retryButton,
                                    style: .cyan,
                                    width: 100,
                                    height: 40
                                ) {
                                    errorManager.clear()
                                }

                                PrimaryButton(
                                    title: ErrorView.cancelButton,
                                    style: .white,
                                    width: 100,
                                    height: 40
                                ) {
                                    errorManager.clear()
                                }
                            }

                        case .acknowledge:
                            PrimaryButton(
                                title: ErrorView.confirmButton,
                                style: .cyan,
                                width: 120,
                                height: 44
                            ) {
                                errorManager.clear()
                            }

                        case .fatal:
                            PrimaryButton(
                                title: ErrorView.exitAppButton,
                                style: .red,
                                width: 120,
                                height: 44
                            ) {
                                exit(0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
            }
        }
    }

    // 에러 심각도에 따른 아이콘 반환
    private func errorIcon(for severity: SystemErrorSeverity) -> String {
        switch severity {
        case .retry:
            return "arrow.clockwise"
        case .acknowledge:
            return "exclamationmark.triangle.fill"
        case .fatal:
            return "xmark.octagon.fill"
        }
    }

    // 에러 심각도에 따른 색상 반환
    private func errorColor(for severity: SystemErrorSeverity) -> Color {
        switch severity {
        case .retry:
            return .dsWarning
        case .acknowledge:
            return .dsWarning
        case .fatal:
            return .dsError
        }
    }
}



#Preview {
    ErrorView()
        .environment({
            let manager = ErrorManager()
            manager.report(.databaseRequestFailed)
            return manager
        }())
}
