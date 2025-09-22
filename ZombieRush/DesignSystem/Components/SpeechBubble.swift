//
//  SpeechBubble.swift
//  ZombieRush
//
//  Created by 김민성 on 9/10/25.
//

import SwiftUI

struct SpeechBubble: Shape {
    var cornerRadius: CGFloat = 8
    var tailWidth: CGFloat = 20
    var tailHeight: CGFloat = 10
    var tailAlignment: Alignment = .trailing  // 꼬리 위치
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tailBaseX: CGFloat
        switch tailAlignment {
        case .leading:
            tailBaseX = cornerRadius + 16
        case .trailing:
            tailBaseX = rect.maxX - cornerRadius - 16 - tailWidth
        default:
            tailBaseX = rect.midX - tailWidth / 2
        }
        
        // 좌상단 모서리부터 시계방향으로 Path 생성
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        
        // 👉 오른쪽-아래 모서리 지나서 꼬리 들어감
        path.addLine(to: CGPoint(x: tailBaseX + tailWidth, y: rect.height))
        path.addLine(to: CGPoint(x: tailBaseX + tailWidth / 2, y: rect.height + tailHeight))
        path.addLine(to: CGPoint(x: tailBaseX, y: rect.height))
        
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}



