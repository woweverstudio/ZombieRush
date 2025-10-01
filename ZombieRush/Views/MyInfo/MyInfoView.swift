import SwiftUI
import Foundation  // StatType을 위해 추가

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("my_info_title", tableName: "MyInfo", comment: "My info title")
    static let selectItemPrompt = NSLocalizedString("select_item_prompt", tableName: "MyInfo", comment: "Select item prompt")
    static let selectItemInstruction = NSLocalizedString("select_item_instruction", tableName: "MyInfo", comment: "Select item instruction")
    static let cheerBuffTitle = NSLocalizedString("cheer_buff_title", tableName: "MyInfo", comment: "Cheer buff title")
    static let cheerBuffOn = NSLocalizedString("cheer_buff_on", tableName: "MyInfo", comment: "Cheer buff on")
    static let cheerBuffOff = NSLocalizedString("cheer_buff_off", tableName: "MyInfo", comment: "Cheer buff off")
}

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var statsRepository: SupabaseStatsRepository
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

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
            title: MyInfoView.myInfoTitle,
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

                    Text(verbatim: MyInfoView.selectItemPrompt)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)

                    Text(verbatim: MyInfoView.selectItemInstruction)
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
                    Text(verbatim: category.localizedDisplayName)
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
                    let isUnlocked = jobsRepository.currentJobs?.unlockedJobs.contains(jobType) ?? false
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
                    let currentValue = getCurrentStatValue(by: statType)

                    StatInfoCard(
                        statType: statType,
                        isSelected: isSelected,
                        currentValue: currentValue,
                        onTap: {
                            selectedStat = statType
                        }
                    )
                }
                
                SelectionInfoCard(
                    title: MyInfoView.cheerBuffTitle,
                    iconName: "medal.fill",
                    iconColor: Color.dsSuccess,
                    value: "\(userRepository.currentUser?.isCheerBuffActive ?? false ? MyInfoView.cheerBuffOn : MyInfoView.cheerBuffOff)",
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
                    let currentCount = getCurrentSpiritCount(by: spiritType)

                    SpiritInfoCard(
                        spiritType: spiritType,
                        isSelected: isSelected,
                        currentCount: currentCount,
                        onTap: {
                            selectedSpirit = spiritType
                        }
                    )
                }
            }
        }
    }
    
    private func getCurrentStatValue(by statType: StatType) -> Int {
        guard let stats = statsRepository.currentStats else { return 0 }

        return stats[statType]
    }
    
    private func getCurrentSpiritCount(by spiritType: SpiritType) -> Int {
        guard let spirits = spiritsRepository.currentSpirits else { return 0 }
        
        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .lightning: return spirits.lightning
        case .dark: return spirits.dark
        }
    }

}





// MARK: - Preview
#Preview {
    MyInfoView()
}
