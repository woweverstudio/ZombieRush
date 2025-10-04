import SwiftUI

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("my_info_title", tableName: "MyInfo", comment: "My info title")
    static let elementsSection = NSLocalizedString("elements_section", tableName: "MyInfo", comment: "Elements section title")
    static let jobsSection = NSLocalizedString("jobs_section", tableName: "MyInfo", comment: "Jobs section title")
}

// MARK: - Helper Functions
extension MyInfoView {
    // 현재 레벨 가져오기
    private func getCurrentLevel() -> Int {
        guard let user = userRepository.currentUser else { return 1 }
        return user.levelInfo.currentLevel
    }

    // 직업 해금 가능 여부 확인
    private func canUnlockJob(_ jobType: JobType) -> Bool {
        guard let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) else {
            return false
        }

        let levelMet = getCurrentLevel() >= requirement.requiredLevel

        if let spiritType = SpiritType(rawValue: requirement.requiredSpirit) {
            let spiritMet = getSpiritCount(for: spiritType) >= requirement.requiredCount
            return levelMet && spiritMet
        }

        return levelMet
    }

    // 원소 개수 가져오기
    private func getSpiritCount(for spiritType: SpiritType) -> Int {
        guard let spirits = spiritsRepository.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .thunder: return spirits.thunder
        case .dark: return spirits.dark
        }
    }

    // 모든 원소 개수를 딕셔너리로 반환
    private func createSpiritCounts() -> [SpiritType: Int] {
        var counts: [SpiritType: Int] = [:]
        for spiritType in SpiritType.allCases {
            counts[spiritType] = getSpiritCount(for: spiritType)
        }
        return counts
    }

    // 네모잼 개수 가져오기
    private func getNemoFruitCount() -> Int {
        guard let user = userRepository.currentUser else { return 0 }
        return user.nemoFruit
    }
}

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    // 팝업 상태 관리
    @State private var selectedSpiritType: SpiritType?
    @State private var selectedJobType: JobType?
    @State private var purchaseCount = 1

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()
            
            VStack(spacing: 20) {
                headerView
                ScrollView {
                    VStack(spacing: 24) {
                        elementsSection
                        jobsSection
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
        }
        .sheet(item: $selectedSpiritType) { spiritType in
            SpiritPurchaseSheet(
                spiritType: spiritType,
                purchaseCount: $purchaseCount,
                availableNemoFruits: getNemoFruitCount(),
                onPurchase: {
                    Task {
                        let request = AddSpiritRequest(spiritType: spiritType, count: purchaseCount)
                        let _ = await useCaseFactory.addSpirit.execute(request)

                        purchaseCount = 1
                        selectedSpiritType = nil
                    }
                }
            )
        }
        .sheet(item: $selectedJobType) { jobType in
            let isUnlocked = jobsRepository.currentJobs?.unlockedJobs.contains(jobType) ?? false
            let spiritCounts = createSpiritCounts()

            if isUnlocked {
                JobOwnedSheet(jobType: jobType)
            } else {
                JobUnlockSheet(
                    jobType: jobType,
                    currentLevel: getCurrentLevel(),
                    spiritCounts: spiritCounts,
                    onUnlock: {
                        Task {
                            let request = UnlockJobRequest(jobType: jobType)
                            let _ = await useCaseFactory.unlockJob.execute(request)

                            selectedJobType = nil

                        }
                    }
                )
            }
        }
    }

}

// MARK: - Sub Views
extension MyInfoView {
    private var headerView: some View {
        Header(
            title: MyInfoView.myInfoTitle,
            badges: [.nemoFruits],
            onBack: {
                router.quitToMain()
            }
        )
    }

    private var elementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(MyInfoView.elementsSection)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(SpiritType.allCases, id: \.self) { spiritType in
                    ElementCard(
                        spiritType: spiritType,
                        count: getSpiritCount(for: spiritType),
                        onTap: {
                            selectedSpiritType = spiritType
                            purchaseCount = 1
                        }
                    )
                }
            }
        }
    }

    private var jobsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(MyInfoView.jobsSection)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)

            if let jobs = jobsRepository.currentJobs {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(JobType.allCases, id: \.self) { jobType in
                        MyInfoJobCard(
                            jobType: jobType,
                            isUnlocked: jobs.unlockedJobs.contains(jobType),
                            onTap: {
                                selectedJobType = jobType
                            }
                        )
                    }
                }
            }
        }
    }

}





// MARK: - Preview
#Preview {
    @Previewable @StateObject var userRepository: SupabaseUserRepository = SupabaseUserRepository()
    @Previewable @StateObject var statsRepository: SupabaseStatsRepository = SupabaseStatsRepository()
    @Previewable @StateObject var spiritsRepository: SupabaseSpiritsRepository = SupabaseSpiritsRepository()
    @Previewable @StateObject var jobsRepository: SupabaseJobsRepository = SupabaseJobsRepository()

    MyInfoView()
        .environment(AppRouter())
        .environmentObject(
            UseCaseFactory(userRepository: userRepository, statsRepository: statsRepository, spiritsRepository: spiritsRepository, jobsRepository: jobsRepository)
        )
        .environmentObject(userRepository)
        .environmentObject(spiritsRepository)
        .environmentObject(jobsRepository)

}
