//
//  RequirementsTable.swift
//  ZombieRush
//
//  Created by 김민성 on 10/5/25.
//

import SwiftUI

struct RequirementsTable: View {
    let currentValue: Int // 현재 조건
    let requiredValue: Int // 필요 조건
    let isMet: Bool // 충족여부
    let unit: String //레벨, 원소명
    
    var tableHeader: some View {
        HStack(spacing: 0) {
            Text(String(format: JobUnlockSheet.currentValue, unit))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)

            Text(String(format: JobUnlockSheet.requiredValue, unit))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)

            Text(isMet ? JobUnlockSheet.pass : JobUnlockSheet.unpass)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.05))
    }
    
    var tableBody: some View {
        // 표 내용
        HStack(spacing: 0) {
            Text("\(currentValue)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(isMet ? .green : .white)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("\(requiredValue)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .frame(maxWidth: .infinity, alignment: .center)

            if isMet {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 6)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            tableHeader
            tableBody
        }
    }
}
