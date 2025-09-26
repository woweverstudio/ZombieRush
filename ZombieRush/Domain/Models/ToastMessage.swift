//
//  ToastMessage.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

enum ToastType {
    case complete
    case celebrate
    case error
    
    var imageName: String {
        switch self {
        case .complete:
            return "checkmark.circle.fill"
        case .celebrate:
            return "sparkles"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .complete:
            return .green
        case .celebrate:
            return .yellow
        case .error:
            return .red
        }
    }
}

struct ToastMessage: Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let duration: TimeInterval
    let type: ToastType
    
    init(title: String, description: String?, duration: TimeInterval = 2.0, type: ToastType = .complete) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.duration = duration
        self.type = type
    }
}
