import SwiftUI

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @Environment(JobsStateManager.self) var jobsStateManager
    @Environment(StatsStateManager.self) var statsStateManager
    @Environment(UserStateManager.self) var userStateManager

    let initialCategory: MyInfoCategory
    @State private var selectedCategory: MyInfoCategory
    @State private var selectedJob: JobType? = nil
    @State private var selectedStat: StatType? = nil

    init(initialCategory: MyInfoCategory = .jobs) {
        self.initialCategory = initialCategory
        self._selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 0) {
                headerView

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
        HStack {
            // 뒤로가기 버튼
            NeonIconButton(icon: "chevron.left", style: .white) {
                router.quitToMain()
            }

            Spacer()

            // 타이틀
            Text("내 정보")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: Color.cyan, radius: 10, x: 0, y: 0)

            Spacer()

            // 스텟 포인트 표시 (스텟 카테고리일 때만)
            if selectedCategory == .stats {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                    Text("\(userStateManager.remainingPoints)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var leftPanelView: some View {
        VStack(spacing: 16) {
            categoryTabsView

            if selectedCategory == .jobs {
                jobsGridView
            } else {
                statsGridView
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var categoryTabsView: some View {
        HStack(spacing: 8) {
            ForEach(MyInfoCategory.allCases, id: \.self) { category in
                Button(action: {
                    // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
                    DispatchQueue.global(qos: .userInteractive).async {
                        AudioManager.shared.playButtonSound()
                        HapticManager.shared.playButtonHaptic()
                    }

                    // 즉시 액션 실행 (UI 반응성 최우선)
                    selectedCategory = category
                    selectedJob = nil // 카테고리 변경 시 선택 해제
                    selectedStat = nil
                }) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedCategory == category ? Color.cyan.opacity(0.2) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedCategory == category ? Color.cyan : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
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
            }
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

// MARK: - Job Info Card
struct JobInfoCard: View {
    let jobType: JobType
    let isUnlocked: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // 직업 아이콘
                    Image(systemName: jobType.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isUnlocked ? .white : .gray.opacity(0.5))
                        .frame(width: 50, height: 50)

                    // 잠금 오버레이
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: 24, height: 24)
                            )
                    }
                }

                // 직업 이름
                Text(jobType.displayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isUnlocked ? .white : .gray.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : (isUnlocked ? Color.white.opacity(0.2) : Color.gray.opacity(0.3)), lineWidth: 1)
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

// MARK: - Stat Info Card
struct StatInfoCard: View {
    let statType: StatType
    let isSelected: Bool
    let currentValue: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 스텟 아이콘
                Image(systemName: statType.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(statType.color)
                    .frame(width: 50, height: 50)

                // 스텟 이름
                Text(statType.displayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 현재 값
                Text("\(currentValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Job Detail Panel
struct JobDetailPanel: View {
    let jobType: JobType

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: jobType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.cyan)

                Text(jobType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // 스텟 정보
            VStack(alignment: .leading, spacing: 12) {
                Text("기본 스텟")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)

                let stats = JobStats.getStats(for: jobType.rawValue)

                StatInfoRow(icon: "heart.fill", label: "체력", value: stats.hp)
                StatInfoRow(icon: "bolt.fill", label: "에너지", value: stats.energy)
                StatInfoRow(icon: "figure.run", label: "이동속도", value: stats.move)
                StatInfoRow(icon: "target", label: "공격속도", value: stats.attackSpeed)
            }

            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Stat Detail Panel
struct StatDetailPanel: View {
    let statType: StatType
    @Environment(StatsStateManager.self) var statsStateManager
    @Environment(UserStateManager.self) var userStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: statType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(statType.color)

                Text(statType.displayName)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // 현재 값 표시
                Text("\(getCurrentStatValue())")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // 설명
            VStack(alignment: .leading, spacing: 12) {
                Text("설명")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(statType.color)

                Text(statType.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }

            Spacer()

            // 업그레이드 버튼
            NeonButton("업그레이드 (1 포인트)", fullWidth: true, size: .small) {
                Task {
                    await upgradeStat()
                }
            }
            .disabled(userStateManager.remainingPoints < 1)
            .opacity(userStateManager.remainingPoints >= 1 ? 1.0 : 0.5)
        }
        .padding(20)
    }

    private func getCurrentStatValue() -> Int {
        guard let stats = statsStateManager.currentStats else { return 0 }

        switch statType {
        case .hpRecovery: return stats.hpRecovery
        case .moveSpeed: return stats.moveSpeed
        case .energyRecovery: return stats.energyRecovery
        case .attackSpeed: return stats.attackSpeed
        case .totemCount: return stats.totemCount
        }
    }

    private func upgradeStat() async {
        // 포인트 차감 (포인트 확인 및 차감은 메소드 내부에서 처리)
        let success = await userStateManager.consumeRemainingPoints(1)

        if success {
            // 스텟 업그레이드
            await statsStateManager.upgradeStat(statType)
        } else {
            print("❌ 포인트가 부족합니다")
        }
    }
}

// MARK: - Stat Info Row
struct StatInfoRow: View {
    let icon: String
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 60, alignment: .leading)

            Spacer()

            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    MyInfoView()
}
