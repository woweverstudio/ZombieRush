import SwiftUI

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("my_info_title", tableName: "MyInfo", comment: "My info title")
    static let elementsSection = NSLocalizedString("elements_section", tableName: "MyInfo", comment: "Elements section title")
    static let jobsSection = NSLocalizedString("jobs_section", tableName: "MyInfo", comment: "Jobs section title")
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
            spiritPurchaseSheet(for: spiritType)
        }
        .sheet(item: $selectedJobType) { jobType in
            if let jobs = jobsRepository.currentJobs {
                jobUnlockSheet(for: jobType, isUnlocked: jobs.unlockedJobs.contains(jobType))
            } else {
                jobUnlockSheet(for: jobType, isUnlocked: false)
            }
        }
    }

    // MARK: - Spirit Purchase Sheet
    private func spiritPurchaseSheet(for spiritType: SpiritType) -> some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 20) {
                Header(title: "원소 구입", showBackButton: false)
                
                // 원소 정보
                HStack(spacing: 12) {
                    Image(systemName: spiritType.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(spiritType.color)

                    VStack(alignment:.leading, spacing: 8) {
                        Text(spiritType.localizedDisplayName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text(spiritType.localizedDescription)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Divider()
                
                Spacer()
                HStack(spacing: 16) {
                    SecondaryButton(title: "-", style: .default, fontSize: 24, size: .init(width: 60, height: 45)) {
                        if purchaseCount > 1 {
                            purchaseCount -= 1
                        }
                    }
                    
                    HStack {
                        CommonBadge(image: Image("nemo_single"), value: purchaseCount, size: 28, color: .cyan)
                        Text("➔")
                        CommonBadge(image: Image(systemName: spiritType.iconName), value: purchaseCount, size: 28, color: spiritType.color)
                    }
                    
                    SecondaryButton(title: "+", style: .default, fontSize: 24, size: .init(width: 60, height: 45)) {
                        if purchaseCount < 99 {
                            purchaseCount += 1
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity)
                Divider()
                
                PrimaryButton(title: "원소 얻기", style: .cyan, fullWidth: true){
                    Task {
                        let request = AddSpiritRequest(spiritType: spiritType, count: purchaseCount)
                        let _ = await useCaseFactory.addSpirit.execute(request)
                        
                        purchaseCount = 1
                        selectedSpiritType = nil
                    }
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
        .presentationDetents([.medium])
    }

    // MARK: - Job Unlock Sheet
    private func jobUnlockSheet(for jobType: JobType, isUnlocked: Bool) -> some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 20) {
                Header(title: "직업 해금", showBackButton: false)

                // 직업 정보
                VStack(spacing: 20) {
                    // 큰 이미지
                    Image(jobType.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)

                    VStack(spacing: 8) {
                        Text(jobType.localizedDisplayName)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        // 직업 설명 (임시)
                        Text(getJobDescription(for: jobType))
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    
                }
                
                Divider()
                Spacer()
                
                // 요구사항 표시
                if let requirement = JobUnlockRequirement.requirement(for: jobType.rawValue) {
                    VStack(spacing: 16) {
                        Text("해금 요구사항")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        HStack(spacing: 24) {
                            // 레벨 요구사항
                            requirementCard(
                                title: "레벨",
                                value: "\(requirement.requiredLevel)",
                                currentValue: getCurrentLevel(),
                                isMet: getCurrentLevel() >= requirement.requiredLevel,
                                iconName: "star.fill",
                                iconColor: .cyan
                            )

                            // 원소 요구사항
                            if let spiritType = SpiritType(rawValue: requirement.requiredSpirit) {
                                requirementCard(
                                    title: "원소",
                                    value: "\(requirement.requiredCount)",
                                    currentValue: getSpiritCount(for: spiritType),
                                    isMet: getSpiritCount(for: spiritType) >= requirement.requiredCount,
                                    iconName: spiritType.iconName,
                                    iconColor: spiritType.color
                                )
                            }
                        }
                    }
                }

                // 해금하기 버튼
                if isUnlocked {
                    PrimaryButton(title: "이미 해금됨", style: .disabled, fullWidth: true) {
                        selectedJobType = nil
                    }
                } else {
                    let canUnlock = canUnlockJob(jobType)
                    PrimaryButton(
                        title: "직업 해금",
                        style: canUnlock ? .cyan : .disabled,
                        fullWidth: true
                    ) {
                        if canUnlock {
                            Task {
                                let request = UnlockJobRequest(jobType: jobType)
                                let response = await useCaseFactory.unlockJob.execute(request)

                                if response.success {
                                    selectedJobType = nil
                                }
                            }
                        }
                    }
                    .disabled(!canUnlock)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
    }

    // 임시 직업 설명
    private func getJobDescription(for jobType: JobType) -> String {
        switch jobType {
        case .novice:
            return "기본 직업입니다"
        case .fireMage:
            return "불 속성 마법을 사용합니다"
        case .iceMage:
            return "얼음 속성 마법을 사용합니다"
        case .thunderMage:
            return "번개 속성 마법을 사용합니다"
        case .darkMage:
            return "어둠 속성 마법을 사용합니다"
        }
    }

    // 요구사항 카드
    private func requirementCard(title: String, value: String, currentValue: Int, isMet: Bool, iconName: String, iconColor: Color) -> some View {
        VStack(spacing: 8) {
            // 아이콘과 체크마크
            ZStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)

                if isMet {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }

            Text(title)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 2) {
                Text("\(currentValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isMet ? .green : .white)

                Text("/")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))

                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isMet ? .green : .cyan)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isMet ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isMet ? Color.green.opacity(0.3) : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

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
                    elementCard(for: spiritType)
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
                        jobCard(for: jobType, isUnlocked: jobs.unlockedJobs.contains(jobType))
                    }
                }
            }
        }
    }

    private func elementCard(for spiritType: SpiritType) -> some View {

        Card(style: .cyberpunk) {
            HStack {
                VStack(spacing: 6){
                    Image(systemName: spiritType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(spiritType.color)
                        .frame(width: 32)

                    Text(spiritType.localizedDisplayName)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.dsTextSecondary)
                }
                .frame(width: 60)

                Text("\(getSpiritCount(for: spiritType))")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(8)
        }
        .frame(height: 80)
        .contentShape(Rectangle())
        .onTapGesture {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()
            
            selectedSpiritType = spiritType
            purchaseCount = 1
        }
        
    }

    private func jobCard(for jobType: JobType, isUnlocked: Bool = true) -> some View {
        Card(style: isUnlocked ? .cyberpunk : .disabled) {
            VStack(spacing: 6) {
                Image(jobType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text(jobType.localizedDisplayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
            }
            .padding(6)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            AudioManager.shared.playButtonSound()
            HapticManager.shared.playButtonHaptic()

            selectedJobType = jobType
        }
    }

    private func getSpiritCount(for spiritType: SpiritType) -> Int {
        guard let spirits = spiritsRepository.currentSpirits else { return 0 }

        switch spiritType {
        case .fire: return spirits.fire
        case .ice: return spirits.ice
        case .thunder: return spirits.thunder
        case .dark: return spirits.dark
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
