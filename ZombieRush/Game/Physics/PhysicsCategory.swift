//
//  PhysicsCategory.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1      // 1
    static let platform: UInt32 = 0b10   // 2
    static let enemy: UInt32 = 0b100     // 4
    static let bullet: UInt32 = 0b1000   // 8
    static let powerUp: UInt32 = 0b10000 // 16
    static let worldBorder: UInt32 = 0b100000 // 32
    static let item: UInt32 = 0b1000000  // 64
    static let all: UInt32 = UInt32.max
}
