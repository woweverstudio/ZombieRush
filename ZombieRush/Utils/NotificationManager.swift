//
//  NotificationManager.swift
//  ZombieRush
//
//  Manages local notifications for the app, specifically weekly Hall of Fame challenges
//

import Foundation
import UserNotifications
import UIKit

/// 요일을 나타내는 enum (UNCalendarNotificationTrigger용)
private enum Weekday: Int {
    case sunday = 1
    case monday = 2
    case saturday = 7

    var koreanName: String {
        switch self {
        case .sunday: return "일요일"
        case .monday: return "월요일"
        case .saturday: return "토요일"
        }
    }
}

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private let mondayNotificationIdentifier = "weekly_hall_of_fame_challenge_monday"
    private let saturdayNotificationIdentifier = "weekly_hall_of_fame_challenge_saturday"

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// 앱 시작 시 Notification 권한을 요청하고 주간 알림을 스케줄링
    func setupNotifications() {
        requestAuthorization { [weak self] granted in
            if granted {
                self?.scheduleWeeklyHallOfFameNotifications()
                print("📱 주간 명예의 전당 알림이 설정되었습니다.")
            } else {
                print("⚠️ 알림 권한이 거부되었습니다.")
            }
        }
    }

    /// Notification 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ 알림 권한 요청 실패: \(error.localizedDescription)")
                completion(false)
                return
            }

            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// 매주 월요일과 토요일 아침 9시에 명예의 전당 도전 알림 스케줄링
    func scheduleWeeklyHallOfFameNotifications() {
        // 기존 알림 취소
        cancelScheduledNotifications()

        // 현재 주차 정보 가져오기
        let currentWeekInfo = DateUtils.getCurrentWeekString()

        // Notification 내용 구성
        let content = UNMutableNotificationContent()
        content.title = TextConstants.App.title
        content.body = String(format: TextConstants.Notification.hallOfFameChallenge, currentWeekInfo)
        content.sound = .default
        content.badge = 1

        // 월요일 알림 스케줄링
        scheduleNotification(for: .monday, with: content, identifier: mondayNotificationIdentifier)

        // 토요일 알림 스케줄링
        scheduleNotification(for: .saturday, with: content, identifier: saturdayNotificationIdentifier)
    }

    /// 특정 요일에 알림 스케줄링 (private 헬퍼 메소드)
    private func scheduleNotification(for weekday: Weekday, with content: UNMutableNotificationContent, identifier: String) {
        // 트리거 설정
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday.rawValue
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Notification 요청 생성
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Notification 스케줄링
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ \(weekday.koreanName) 알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("✅ \(weekday.koreanName) 명예의 전당 알림이 성공적으로 스케줄링되었습니다.")
                print("📅 알림 내용: \(content.body)")
            }
        }
    }

    /// 예정된 모든 알림 취소
    func cancelScheduledNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            mondayNotificationIdentifier,
            saturdayNotificationIdentifier
        ])
        print("🗑️ 기존 주간 알림이 취소되었습니다.")
    }

    /// 모든 알림 취소 (앱 삭제나 사용자 설정 변경 시)
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("🗑️ 모든 알림이 취소되었습니다.")
    }

    /// 현재 예정된 알림 상태 확인
    func checkScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            let hallOfFameRequests = requests.filter {
                $0.identifier == self.mondayNotificationIdentifier ||
                $0.identifier == self.saturdayNotificationIdentifier
            }

            if hallOfFameRequests.isEmpty {
                print("ℹ️ 예정된 명예의 전당 알림이 없습니다.")
            } else {
                for request in hallOfFameRequests {
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        let dayName = request.identifier == self.mondayNotificationIdentifier ? "월요일" : "토요일"
                        print("📱 예정된 \(dayName) 알림: \(request.content.body)")
                        print("📅 다음 알림: \(trigger.nextTriggerDate()?.description ?? "알 수 없음")")
                    }
                }
            }
        }
    }

    /// 현재 주차 정보를 기반으로 알림 내용 업데이트
    func updateNotificationContent() {
        // 현재 주차 정보로 알림 재스케줄링
        scheduleWeeklyHallOfFameNotifications()
    }

    /// 앱 아이콘 배지 제거
    func clearBadge() {
        notificationCenter.setBadgeCount(0) { error in
            if let error = error {
                print("❌ 배지 제거 실패: \(error.localizedDescription)")
            } else {
                print("🔔 배지가 제거되었습니다.")
            }
        }
    }

}
