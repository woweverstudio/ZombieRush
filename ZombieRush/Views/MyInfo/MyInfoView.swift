import SwiftUI

// MARK: - Job Filter
enum JobFilter: CaseIterable {
    case unlock
    case lock
}

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("screen_title_my_info", tableName: "View", comment: "My info screen title")
    static let elementsSection = NSLocalizedString("my_info_elements_section", tableName: "View", comment: "My info elements section title")
    static let jobsSection = NSLocalizedString("my_info_jobs_section", tableName: "View", comment: "My info jobs section title")
    static let jobFilterUnlock = NSLocalizedString("job_filter_unlock", tableName: "View", comment: "Job filter for unlocked jobs")
    static let jobFilterLock = NSLocalizedString("job_filter_lock", tableName: "View", comment: "Job filter for locked jobs")
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

        if let elementType = ElementType(rawValue: requirement.requiredElement) {
            let elementMet = getElementCount(for: elementType) >= requirement.requiredCount
            return levelMet && elementMet
        }

        return levelMet
    }

    // 원소 개수 가져오기
    private func getElementCount(for elementType: ElementType) -> Int {
        guard let elements = elementsRepository.currentElements else { return 0 }

        switch elementType {
        case .fire: return elements.fire
        case .ice: return elements.ice
        case .thunder: return elements.thunder
        case .dark: return elements.dark
        }
    }

    // 모든 원소 개수를 딕셔너리로 반환
    private func createElementCounts() -> [ElementType: Int] {
        var counts: [ElementType: Int] = [:]
        for elementType in ElementType.allCases {
            counts[elementType] = getElementCount(for: elementType)
        }
        return counts
    }

    // 젬 개수 가져오기
    private func getGemCount() -> Int {
        guard let user = userRepository.currentUser else { return 0 }
        return user.gem
    }
}

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var elementsRepository: SupabaseElementsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    // 팝업 상태 관리
    @State private var selectedElementType: ElementType?
    @State private var selectedJobType: JobType?
    @State private var purchaseCount = 1

    // 직업 필터 상태
    @State private var selectedJobFilter: JobFilter = .unlock

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
                    .padding(.vertical, 32)
                }
                .scrollIndicators(.hidden)
            }
            .padding()
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(item: $selectedElementType) { elementType in
            ElementPurchaseSheet(
                elementType: elementType,
                purchaseCount: $purchaseCount,
                availableGem: getGemCount(),
                onPurchase: {
                    Task {
                        let request = AddElementRequest(elementType: elementType, count: purchaseCount)
                        let _ = await useCaseFactory.addElement.execute(request)

                        purchaseCount = 1
                        selectedElementType = nil
                    }
                }
            )
        }
        .sheet(item: $selectedJobType) { jobType in
            let isUnlocked = jobsRepository.currentJobs?.unlockedJobs.contains(jobType) ?? false
            let elementCounts = createElementCounts()

            if isUnlocked {
                JobOwnedSheet(jobType: jobType)
            } else {
                JobUnlockSheet(
                    jobType: jobType,
                    currentLevel: getCurrentLevel(),
                    elementCounts: elementCounts,
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
            badges: [.gem],
            onBack: {
                router.goBack()
            },
            onBadgeTap: { badge in
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()

                switch badge {
                case .gem:
                    router.navigate(to: .market)
                case .statsPoints:
                    // 필요시 다른 액션 추가
                    break
                }
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
                ForEach(ElementType.allCases, id: \.self) { elementType in
                    ElementCard(
                        elementType: elementType,
                        count: getElementCount(for: elementType),
                        onTap: {
                            selectedElementType = elementType
                            purchaseCount = 1
                        }
                    )
                }
            }
        }
    }

    private var jobsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(MyInfoView.jobsSection)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)

            // Segmented Picker
            Picker("", selection: $selectedJobFilter) {
                Text(MyInfoView.jobFilterUnlock)
                    .tag(JobFilter.unlock)
                Text(MyInfoView.jobFilterLock)
                    .tag(JobFilter.lock)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 8)

            if let jobs = jobsRepository.currentJobs {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 8) {
                    ForEach(filteredJobTypes(jobs: jobs), id: \.self) { jobType in
                        let isUnlocked = jobs.unlockedJobs.contains(jobType)

                        MyInfoJobCard(
                            jobType: jobType,
                            isUnlocked: isUnlocked,
                            style: selectedJobFilter == .unlock ? .cyberpunk : .locked,
                            onTap: {
                                selectedJobType = jobType
                            }
                        )
                    }
                }
            }
        }
    }

    private func filteredJobTypes(jobs: Jobs) -> [JobType] {
        JobType.allCases.filter { jobType in
            let isUnlocked = jobs.unlockedJobs.contains(jobType)
            return selectedJobFilter == .unlock ? isUnlocked : !isUnlocked
        }
    }

}
