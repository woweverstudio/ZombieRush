//
////  GlobalErrorManager.swift
////  ZombieRush
////
////  Created by Centralized Error Management System
////

import Foundation
import SwiftUI

/// 전역 에러 상태를 관리하는 Observable 싱글턴 클래스
/// 앱 전체에서 발생하는 에러를 중앙 집중적으로 처리
@Observable
final class GlobalErrorManager {
    // MARK: - Singleton
    static let shared = GlobalErrorManager()

    // MARK: - Properties
    /// 현재 표시할 에러
    private(set) var currentError: AppError?

    /// 에러 팝업 표시 여부
    private(set) var isShowingError = false

    /// 대기 중인 에러 큐 (여러 에러가 동시에 발생하는 경우)
    private var errorQueue: [AppError] = []

    // MARK: - Initialization
    private init() {
        // 외부에서 생성 방지
    }

    // MARK: - Public Methods

    /// 네트워크 에러를 표시합니다. (비즈니스 에러는 표시하지 않음)
    /// - Parameter error: 표시할 네트워크 에러
    func showError(_ error: AppError) {
        // 네트워크 에러가 아니면 무시
        guard error.isNetworkError else {
            print("📱 GlobalErrorManager: 비즈니스 에러는 무시 - \(error)")
            return
        }

        // 메인 스레드에서 실행
        Task { @MainActor in
            if isShowingError {
                // 현재 에러 표시 중이면 큐에 추가
                errorQueue.append(error)
            } else {
                // 즉시 표시
                currentError = error
                isShowingError = true
            }

            // 로깅
            if let title = error.title {
                print("📱 GlobalErrorManager: 시스템 에러 표시 - \(title)")
            }
        }
    }

    /// 현재 에러를 닫고 다음 대기 중인 에러를 표시합니다.
    func dismissError() {
        Task { @MainActor in
            currentError = nil
            isShowingError = false

            // 큐에서 다음 에러 표시
            if let nextError = errorQueue.first {
                errorQueue.removeFirst()
                showError(nextError)
            }
        }
    }

    /// 모든 대기 중인 에러를 클리어합니다.
    func clearAllErrors() {
        Task { @MainActor in
            errorQueue.removeAll()
            currentError = nil
            isShowingError = false
        }
    }

    // MARK: - Debug Methods
    #if DEBUG
    /// 현재 상태를 출력합니다 (디버그용)
    func printCurrentState() {
        print("📱 GlobalErrorManager 상태:")
        print("  - 현재 에러 표시 중: \(isShowingError)")
        print("  - 현재 에러: \(currentError?.title ?? "없음")")
        print("  - 대기 중인 에러 수: \(errorQueue.count)")
    }
    #endif
}
