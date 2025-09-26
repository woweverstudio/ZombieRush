//
//  ToastMessage.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

struct ToastMessage: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let duration: TimeInterval
}
