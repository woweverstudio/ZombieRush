//
//  ToastMesageCase.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

enum ToastMessageCase {
    case statPointsIncreased(String, Int)   // 스탯 포인트 증가
    case loginSuccess(String)       // 로그인 성공 (닉네임 포함)
    case cheerBuffPurchased         // 네모의 응원 구입
    case spiritPurchased(String)    // 특정 정령 구입 (이름 포함)
    case lackOfRemaingStatPoints
    
    var toast: ToastMessage {
        switch self {
        case .statPointsIncreased(let name, let points):
            return ToastMessage(
                title: "스텟 강화 성공",
                description: "\(name) 스탯 포인트 +\(points)",
                type: .celebrate
            )
        case .loginSuccess(let nickname):
            return ToastMessage(
                title: "환영합니다, \(nickname)님!",
                description: "로그인이 완료되었습니다.",
                type: .complete
                
            )
        case .cheerBuffPurchased:
            return ToastMessage(
                title: "네모의 응원 활성화 🎉",
                description: "일정 시간 동안 네모구출, 정령 발견 능력이 향상됩니다.",
                duration: 3.0,
                type: .celebrate
            )
        case .spiritPurchased(let spiritName):
            return ToastMessage(
                title: "\(spiritName) 정령 획득 ✨",
                description: "새로운 정령을 획득했습니다.",
                type: .celebrate
            )
        case .lackOfRemaingStatPoints:
            return ToastMessage(
                title: "스탯 포인트 부족",
                description: "스탯 포인트가 부족합니다.",
                duration: 2.0,
                type: .error
            )
        }
    }
}
