//
////  ErrorPopupView.swift
////  ZombieRush
////
////  Created by Error Popup View for displaying detailed error information
////

import SwiftUI

/// 시스템 에러 상세 정보를 표시하는 팝업 뷰
/// 시스템 에러 아이콘, 제목, 설명, 확인 버튼 포함
struct ErrorPopupView: View {
    // MARK: - Properties
    let error: AppError

    // MARK: - Environment
    @Environment(GlobalErrorManager.self) private var errorManager

    // MARK: - Computed Properties
    private var title: String {
        error.title ?? "알 수 없는 오류"
    }

    private var message: String {
        error.userFriendlyMessage ?? "예상치 못한 오류가 발생했습니다."
    }

    private var icon: Image {
        error.icon ?? Image(systemName: "exclamationmark.triangle")
    }

    private var color: Color {
        error.color ?? .gray
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // 시스템 에러 아이콘
            icon
                .font(.system(size: 50))
                .foregroundColor(color)
                .padding(.top, 10)

            // 시스템 에러 제목
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // 시스템 에러 설명 (문제 설명)
            VStack(spacing: 8) {
                Text("문제 설명")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)

                Text(message)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            // 확인 버튼
            PrimaryButton(
                title: "확인",
                style: .cyan,
                fullWidth: false
            ) {
                // 시스템 에러 닫기
                errorManager.dismissError()
            }
            .padding(.top, 10)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 20)
        )
        .frame(maxWidth: 320)
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview
#Preview("포인트 부족 에러") {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        ErrorPopupView(error: .business(.insufficientPoints(needed: 5, current: 2)))
            .environment(GlobalErrorManager.shared)
    }
}

#Preview("네트워크 에러") {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        ErrorPopupView(error: .network(.timeout))
            .environment(GlobalErrorManager.shared)
    }
}
