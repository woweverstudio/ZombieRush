//
////  ErrorOverlayView.swift
////  ZombieRush
////
////  Created by Global Error Overlay View
////

import SwiftUI

/// 앱 전체에 걸쳐 표시되는 에러 오버레이 뷰
/// 반투명 배경 + 에러 팝업을 표시
struct ErrorOverlayView: View {
    // MARK: - Environment
    @Environment(GlobalErrorManager.self) private var errorManager

    // MARK: - Body
    var body: some View {
        ZStack {
            // 에러 표시 중일 때만 오버레이 표시
            if errorManager.isShowingError, let error = errorManager.currentError {
                // 반투명 배경 오버레이
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 배경 터치 시 에러 닫기
                        errorManager.dismissError()
                    }

                // 에러 팝업
                ErrorPopupView(error: error)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1) // 팝업을 최상단에 표시
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: errorManager.isShowingError)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // 배경 컨텐츠
        Color.blue
            .ignoresSafeArea()

        // 에러 오버레이
        ErrorOverlayView()
            .environment(GlobalErrorManager.shared)
    }
}
