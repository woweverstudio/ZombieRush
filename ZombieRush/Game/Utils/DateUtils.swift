import Foundation

/// 날짜 관련 유틸리티 클래스
class DateUtils {

    /// 오늘 날짜를 기준으로 몇월 몇번째 주인지 계산해서 문자열로 반환
    /// - Returns: "9월 3주차" 또는 "September 3rd week" 형태의 문자열
    static func getCurrentWeekString() -> String {
        let calendar = Calendar.current
        let today = Date()

        // 현재 월과 일 가져오기
        let month = calendar.component(.month, from: today)

        // 해당 월의 첫 번째 날짜
        let firstDayOfMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: today),
                                                               month: month,
                                                               day: 1))!

        // 첫 번째 날짜의 요일 (1: 일요일, 2: 월요일, ..., 7: 토요일)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // 첫 번째 날짜가 속한 주의 시작일 계산
        // (첫 번째 날짜가 일요일이면 그 주의 시작, 아니면 이전 주의 시작)
        let weekStartOffset = (firstWeekday == 1) ? 0 : -(firstWeekday - 1)
        let weekStartDate = calendar.date(byAdding: .day, value: weekStartOffset, to: firstDayOfMonth)!

        // 오늘 날짜가 몇 번째 주인지 계산
        let weekNumber = calendar.dateComponents([.weekOfMonth], from: weekStartDate, to: today).weekOfMonth! + 1

        // 현지화된 월 이름 가져오기
        let monthName = getLocalizedMonthName(month)

        // 현지화된 주차 포맷으로 반환
        return String(format: NSLocalizedString("WEEK_FORMAT", comment: "Week format for date display"), monthName, weekNumber, getOrdinalSuffix(weekNumber))
    }

    /// 특정 날짜를 기준으로 몇월 몇번째 주인지 계산해서 문자열로 반환
    /// - Parameter date: 기준 날짜
    /// - Returns: 현지화된 주차 문자열
    static func getWeekString(for date: Date) -> String {
        let calendar = Calendar.current

        // 해당 월과 일 가져오기
        let month = calendar.component(.month, from: date)

        // 해당 월의 첫 번째 날짜
        let firstDayOfMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: date),
                                                               month: month,
                                                               day: 1))!

        // 첫 번째 날짜의 요일 (1: 일요일, 2: 월요일, ..., 7: 토요일)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // 첫 번째 날짜가 속한 주의 시작일 계산
        let weekStartOffset = (firstWeekday == 1) ? 0 : -(firstWeekday - 1)
        let weekStartDate = calendar.date(byAdding: .day, value: weekStartOffset, to: firstDayOfMonth)!

        // 해당 날짜가 몇 번째 주인지 계산
        let weekNumber = calendar.dateComponents([.weekOfMonth], from: weekStartDate, to: date).weekOfMonth! + 1

        // 현지화된 월 이름 가져오기
        let monthName = getLocalizedMonthName(month)

        // 현지화된 주차 포맷으로 반환
        return String(format: NSLocalizedString("WEEK_FORMAT", comment: "Week format for date display"), monthName, weekNumber, getOrdinalSuffix(weekNumber))
    }

    /// 현재 날짜의 주차 정보를 상세하게 반환
    /// - Returns: (월, 주차) 튜플
    static func getCurrentWeekInfo() -> (month: Int, week: Int) {
        let calendar = Calendar.current
        let today = Date()

        let month = calendar.component(.month, from: today)

        // 해당 월의 첫 번째 날짜
        let firstDayOfMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: today),
                                                               month: month,
                                                               day: 1))!

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // 첫 번째 날짜가 속한 주의 시작일 계산
        let weekStartOffset = (firstWeekday == 1) ? 0 : -(firstWeekday - 1)
        let weekStartDate = calendar.date(byAdding: .day, value: weekStartOffset, to: firstDayOfMonth)!

        // 오늘 날짜가 몇 번째 주인지 계산
        let weekNumber = calendar.dateComponents([.weekOfMonth], from: weekStartDate, to: today).weekOfMonth! + 1

        return (month, weekNumber)
    }

    /// 월 번호에 해당하는 현지화된 월 이름 반환
    /// - Parameter month: 월 번호 (1-12)
    /// - Returns: 현지화된 월 이름
    private static func getLocalizedMonthName(_ month: Int) -> String {
        let monthKeys = [
            "", // 0번 인덱스 사용 안 함
            "MONTH_JANUARY",
            "MONTH_FEBRUARY",
            "MONTH_MARCH",
            "MONTH_APRIL",
            "MONTH_MAY",
            "MONTH_JUNE",
            "MONTH_JULY",
            "MONTH_AUGUST",
            "MONTH_SEPTEMBER",
            "MONTH_OCTOBER",
            "MONTH_NOVEMBER",
            "MONTH_DECEMBER"
        ]

        guard month >= 1 && month <= 12 else { return "" }

        return NSLocalizedString(monthKeys[month], comment: "Month name - \(monthKeys[month])")
    }

    /// 영어에서 서수 접미사 반환 (1st, 2nd, 3rd, etc.)
    /// - Parameter number: 숫자
    /// - Returns: 서수 접미사
    private static func getOrdinalSuffix(_ number: Int) -> String {
        let suffixes = ["th", "st", "nd", "rd"]
        let lastDigit = number % 10
        let lastTwoDigits = number % 100

        // 11, 12, 13은 예외
        if lastTwoDigits >= 11 && lastTwoDigits <= 13 {
            return suffixes[0] // "th"
        }

        if lastDigit >= 1 && lastDigit <= 3 {
            return suffixes[lastDigit]
        }

        return suffixes[0] // "th"
    }
}
