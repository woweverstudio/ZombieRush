//
//  ToastMesageCase.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

enum ToastMessageCase {
    case levelUp(Int)
    case unlockJobSuccess(String)
    case unlockJobFailed(String, Int, Int)
    case statPointsIncreased(String, Int)   // 스탯 포인트 증가
    case loginSuccess(String)       // 로그인 성공 (닉네임 포함)
    case cheerBuffPurchased         // 네모의 응원 구입
    case spiritPurchased(String)    // 특정 정령 구입 (이름 포함)
    case lackOfRemaingStatPoints
    case selectJobFailed

    // MARK: - Localized Toast
    var toast: ToastMessage {
        switch self {
        case .levelUp(let level):
            return ToastMessage(
                title: NSLocalizedString("toast_level_up_title", tableName: "Models", comment: "Level up toast title"),
                description: String(format: NSLocalizedString("toast_level_up_description", tableName: "Models", comment: "Level up toast description"), level),
                type: .celebrate
            )
        case .unlockJobSuccess(let name):
            return ToastMessage(
                title: NSLocalizedString("toast_job_unlock_success_title", tableName: "Models", comment: "Job unlock success toast title"),
                description: String(format: NSLocalizedString("toast_job_unlock_success_description", tableName: "Models", comment: "Job unlock success toast description"), name),
                type: .celebrate
            )
        case .unlockJobFailed(let spiritName, let spiritCount, let level):
            return ToastMessage(
                title: NSLocalizedString("toast_job_unlock_failed_title", tableName: "Models", comment: "Job unlock failed toast title"),
                description: String(format: NSLocalizedString("toast_job_unlock_failed_description", tableName: "Models", comment: "Job unlock failed toast description"), spiritName, spiritCount, level),
                type: .error
            )
        case .statPointsIncreased(let name, let points):
            return ToastMessage(
                title: NSLocalizedString("toast_stat_increased_title", tableName: "Models", comment: "Stat increased toast title"),
                description: String(format: NSLocalizedString("toast_stat_increased_description", tableName: "Models", comment: "Stat increased toast description"), name, points),
                type: .celebrate
            )
        case .loginSuccess(let nickname):
            return ToastMessage(
                title: String(format: NSLocalizedString("toast_login_success_title", tableName: "Models", comment: "Login success toast title"), nickname),
                description: NSLocalizedString("toast_login_success_description", tableName: "Models", comment: "Login success toast description"),
                type: .complete
            )
        case .cheerBuffPurchased:
            return ToastMessage(
                title: NSLocalizedString("toast_cheer_buff_purchased_title", tableName: "Models", comment: "Cheer buff purchased toast title"),
                description: NSLocalizedString("toast_cheer_buff_purchased_description", tableName: "Models", comment: "Cheer buff purchased toast description"),
                duration: 3.0,
                type: .celebrate
            )
        case .spiritPurchased(let spiritName):
            return ToastMessage(
                title: String(format: NSLocalizedString("toast_spirit_purchased_title", tableName: "Models", comment: "Spirit purchased toast title"), spiritName),
                description: NSLocalizedString("toast_spirit_purchased_description", tableName: "Models", comment: "Spirit purchased toast description"),
                type: .celebrate
            )
        case .lackOfRemaingStatPoints:
            return ToastMessage(
                title: NSLocalizedString("toast_lack_of_stat_points_title", tableName: "Models", comment: "Lack of stat points toast title"),
                description: NSLocalizedString("toast_lack_of_stat_points_description", tableName: "Models", comment: "Lack of stat points toast description"),
                type: .error
            )
        case .selectJobFailed:
            return ToastMessage(
                title: NSLocalizedString("toast_select_job_failed_title", tableName: "Models", comment: "Select job failed toast title"),
                description: NSLocalizedString("toast_select_job_failed_description", tableName: "Models", comment: "Select job failed toast description"),
                type: .error
            )
        }
    }
}
