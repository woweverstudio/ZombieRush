//
//  ToastMesageCase.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

enum ToastMessageCase {
    case statPointsIncreased(Int)   // 스탯 포인트 증가
    case loginSuccess(String)       // 로그인 성공 (닉네임 포함)
    case cheerBuffPurchased         // 네모의 응원 구입
    case spiritPurchased(String)    // 특정 정령 구입 (이름 포함)
    
    var toast: ToastMessage {
        switch self {
        case .statPointsIncreased(let points):
            return ToastMessage(
                title: "스탯 포인트 +\(points)",
                description: "새로운 능력치를 강화해보세요!",
                duration: 2.0
            )
        case .loginSuccess(let nickname):
            return ToastMessage(
                title: "환영합니다, \(nickname)님!",
                description: "로그인이 완료되었습니다.",
                duration: 2.0
            )
        case .cheerBuffPurchased:
            return ToastMessage(
                title: "네모의 응원 활성화 🎉",
                description: "일정 시간 동안 능력이 향상됩니다.",
                duration: 2.0
            )
        case .spiritPurchased(let spiritName):
            return ToastMessage(
                title: "\(spiritName) 정령 획득 ✨",
                description: "새로운 정령이 네모 왕국에 합류했습니다.",
                duration: 2.5
            )
        }
    }
}
