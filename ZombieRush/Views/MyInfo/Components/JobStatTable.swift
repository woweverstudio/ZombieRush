//
//  JobStatTable.swift
//  ZombieRush
//
//  Created by 김민성 on 10/5/25.
//

import SwiftUI

struct JobStatTable: View {
    enum Style {
        case `default`
        case compact
    }
    
    let jobType: JobType
    let style: JobStatTable.Style
    
    var body: some View {
        let stats = JobStats.getStats(for: jobType.rawValue)
        
        Card(style: .cyberpunk) {
            VStack(spacing: 0) {
                if style == .default {
                    Text(JobOwnedSheet.basicStatsTitle)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // 각 스탯별 행 (4개 행)
                JobStatRow(
                    icon: StatType.hp.iconName,
                    label: JobOwnedSheet.hp,
                    value: stats.hp,
                    color: .red,
                    style: style
                )
                
                JobStatRow(
                    icon: StatType.energy.iconName,
                    label: JobOwnedSheet.energy,
                    value: stats.energy,
                    color: .blue,
                    style: style
                )
                
                JobStatRow(
                    icon: StatType.moveSpeed.iconName,
                    label: JobOwnedSheet.moveSpeed,
                    value: stats.moveSpeed,
                    color: .green,
                    style: style
                )
                
                JobStatRow(
                    icon: StatType.attackSpeed.iconName,
                    label: JobOwnedSheet.attackSpeed,
                    value: stats.attackSpeed,
                    color: .orange,
                    style: style
                )
            }
        }
        .padding(.horizontal, 4)
    }
}
