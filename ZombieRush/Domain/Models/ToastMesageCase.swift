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
    case elementPurchased(String)    // 특정 원소 구입 (이름 포함)
    case lackOfRemaingStatPoints
    case selectJobFailed

    // IAP 관련 메시지
    case iapPurchaseSuccess(String)  // 구매 성공 (상품명 포함)
    case iapPurchaseFailed           // 구매 실패

    // MARK: - Localized Toast
    var toast: ToastMessage {
        switch self {
        case .levelUp(let level):
            return ToastMessage(
                title: NSLocalizedString("models_toast_level_up_title", tableName: "Alert", comment: "Level up toast title"),
                description: String(format: NSLocalizedString("models_toast_level_up_description", tableName: "Alert", comment: "Level up toast description"), level),
                type: .celebrate
            )
        case .unlockJobSuccess(let name):
            return ToastMessage(
                title: NSLocalizedString("models_toast_job_unlock_success_title", tableName: "Alert", comment: "Job unlock success toast title"),
                description: String(format: NSLocalizedString("models_toast_job_unlock_success_description", tableName: "Alert", comment: "Job unlock success toast description"), name),
                type: .celebrate
            )
        case .unlockJobFailed(let elementName, let elementCount, let level):
            return ToastMessage(
                title: NSLocalizedString("models_toast_job_unlock_failed_title", tableName: "Alert", comment: "Job unlock failed toast title"),
                description: String(format: NSLocalizedString("models_toast_job_unlock_failed_description", tableName: "Alert", comment: "Job unlock failed toast description"), elementName, elementCount, level),
                type: .error
            )
        case .statPointsIncreased(let name, let points):
            return ToastMessage(
                title: NSLocalizedString("models_toast_stat_increased_title", tableName: "Alert", comment: "Stat increased toast title"),
                description: String(format: NSLocalizedString("models_toast_stat_increased_description", tableName: "Alert", comment: "Stat increased toast description"), name, points),
                type: .celebrate
            )
        case .loginSuccess(let nickname):
            return ToastMessage(
                title: String(format: NSLocalizedString("models_toast_login_success_title", tableName: "Alert", comment: "Login success toast title"), nickname),
                description: NSLocalizedString("models_toast_login_success_description", tableName: "Alert", comment: "Login success toast description"),
                type: .complete
            )
        case .cheerBuffPurchased:
            return ToastMessage(
                title: NSLocalizedString("models_toast_cheer_buff_purchased_title", tableName: "Alert", comment: "Cheer buff purchased toast title"),
                description: NSLocalizedString("models_toast_cheer_buff_purchased_description", tableName: "Alert", comment: "Cheer buff purchased toast description"),
                duration: 3.0,
                type: .celebrate
            )
        case .elementPurchased(let elementName):
            return ToastMessage(
                title: String(format: NSLocalizedString("models_toast_element_purchased_title", tableName: "Alert", comment: "Element purchased toast title"), elementName),
                description: NSLocalizedString("models_toast_element_purchased_description", tableName: "Alert", comment: "Element purchased toast description"),
                type: .celebrate
            )
        case .lackOfRemaingStatPoints:
            return ToastMessage(
                title: NSLocalizedString("models_toast_lack_of_stat_points_title", tableName: "Alert", comment: "Lack of stat points toast title"),
                description: NSLocalizedString("models_toast_lack_of_stat_points_description", tableName: "Alert", comment: "Lack of stat points toast description"),
                type: .error
            )
        case .selectJobFailed:
            return ToastMessage(
                title: NSLocalizedString("models_toast_select_job_failed_title", tableName: "Alert", comment: "Select job failed toast title"),
                description: NSLocalizedString("models_toast_select_job_failed_description", tableName: "Alert", comment: "Select job failed toast description"),
                type: .error
            )

        // IAP 관련 메시지
        case .iapPurchaseSuccess(let productName):
            return ToastMessage(
                title: String(format: NSLocalizedString("models_toast_iap_purchase_success_title", tableName: "Alert", comment: "IAP purchase success toast title"), productName),
                description: NSLocalizedString("models_toast_iap_purchase_success_description", tableName: "Alert", comment: "IAP purchase success toast description"),
                type: .celebrate
            )
        case .iapPurchaseFailed:
            return ToastMessage(
                title: NSLocalizedString("models_toast_iap_purchase_failed_title", tableName: "Alert", comment: "IAP purchase failed toast title"),
                description: NSLocalizedString("models_toast_iap_purchase_failed_description", tableName: "Alert", comment: "IAP purchase failed toast description"),
                type: .error
            )
        }
    }
}
