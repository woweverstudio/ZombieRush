import SwiftUI

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @Environment(JobsStateManager.self) var jobsStateManager
    @Environment(StatsStateManager.self) var statsStateManager
    @Environment(SpiritsStateManager.self) var spiritsStateManager
    @Environment(UserStateManager.self) var userStateManager

    let initialCategory: MyInfoCategory
    @State private var selectedCategory: MyInfoCategory
    @State private var selectedJob: JobType? = nil
    @State private var selectedStat: StatType? = nil
    @State private var selectedSpirit: SpiritType? = nil

    init(initialCategory: MyInfoCategory = .jobs) {
        self.initialCategory = initialCategory
        self._selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 0) {
                headerView
                Spacer()

                // 메인 콘텐츠: 좌측 아이템 리스트 + 우측 상세정보
                HStack(spacing: 20) {
                    leftPanelView
                    rightPanelView
                }
            }
        }
    }
}

// MARK: - Sub Views
extension MyInfoView {
    private var headerView: some View {
        Header(
            title: "내 정보",
            badges: currentBadges,
            onBack: {
                router.quitToMain()
            }
        )
    }

    private var currentBadges: [HeaderBadgeType] {
        switch selectedCategory {
        case .stats:
            return [.statsPoints]
        case .spirits:
            return [.nemoFruits]
        default:
            return []
        }
    }

    private var leftPanelView: some View {
        VStack(spacing: 16) {
            categoryTabsView

            if selectedCategory == .jobs {
                jobsGridView
            } else if selectedCategory == .stats {
                statsGridView
            } else {
                spiritsGridView
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var rightPanelView: some View {
        VStack(spacing: 0) {
            if selectedCategory == .jobs, let job = selectedJob {
                JobDetailPanel(jobType: job)
            } else if selectedCategory == .stats, let stat = selectedStat {
                StatDetailPanel(statType: stat)
            } else if selectedCategory == .spirits, let spirit = selectedSpirit {
                SpiritDetailPanel(spiritType: spirit)
            } else {
                // 선택된 항목이 없을 때의 기본 화면
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("항목을 선택해주세요")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)

                    Text("좌측에서 항목을 클릭하면\n상세 정보를 확인할 수 있습니다")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dsCard, lineWidth: 1)
                )
        )
    }

    private var categoryTabsView: some View {
        HStack(spacing: 8) {
            ForEach(MyInfoCategory.allCases, id: \.self) { category in
                Button(action: {
                    AudioManager.shared.playButtonSound()
                    HapticManager.shared.playButtonHaptic()
                    

                    // 즉시 액션 실행 (UI 반응성 최우선)
                    selectedCategory = category
                    selectedJob = nil // 카테고리 변경 시 선택 해제
                    selectedStat = nil
                    selectedSpirit = nil
                }) {
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedCategory == category ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedCategory == category ? Color.cyan : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var jobsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(JobType.allCases, id: \.self) { jobType in
                    let isUnlocked = jobsStateManager.currentJobs.unlockedJobs.contains(jobType)
                    let isSelected = selectedJob == jobType

                    JobInfoCard(
                        jobType: jobType,
                        isUnlocked: isUnlocked,
                        isSelected: isSelected,
                        onTap: {
                            selectedJob = jobType
                        }
                    )
                }
            }
        }
    }

    private var statsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(StatType.allCases, id: \.self) { statType in
                    let isSelected = selectedStat == statType

                    StatInfoCard(
                        statType: statType,
                        isSelected: isSelected,
                        currentValue: getCurrentStatValue(statType),
                        onTap: {
                            selectedStat = statType
                        }
                    )
                }
                
                SelectionInfoCard(
                    title: "네모의 응원",
                    iconName: "medal.fill",
                    iconColor: Color.dsSuccess,
                    value: "\(userStateManager.isCheerBuffActive ? "ON" : "OFF")",
                    isSelected: false,
                    action: {}
                )
            }
        }
        .scrollIndicators(.never)
    }

    private var spiritsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(SpiritType.allCases, id: \.self) { spiritType in
                    let isSelected = selectedSpirit == spiritType

                    SpiritInfoCard(
                        spiritType: spiritType,
                        isSelected: isSelected,
                        currentCount: getCurrentSpiritCount(spiritType),
                        onTap: {
                            selectedSpirit = spiritType
                        }
                    )
                }
            }
        }
    }

    private func getCurrentSpiritCount(_ spiritType: SpiritType) -> Int {
        guard let spirits = spiritsStateManager.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }

    private func getCurrentStatValue(_ statType: StatType) -> Int {
        guard let stats = statsStateManager.currentStats else { return 0 }

        switch statType {
        case .hpRecovery: return stats.hpRecovery
        case .moveSpeed: return stats.moveSpeed
        case .energyRecovery: return stats.energyRecovery
        case .attackSpeed: return stats.attackSpeed
        case .totemCount: return stats.totemCount
        }
    }
}





// MARK: - Preview
#Preview {
    MyInfoView()
}
