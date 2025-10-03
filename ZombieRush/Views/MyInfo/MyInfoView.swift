import SwiftUI

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("my_info_title", tableName: "MyInfo", comment: "My info title")
    static let elementsSection = NSLocalizedString("elements_section", tableName: "MyInfo", comment: "Elements section title")
    static let jobsSection = NSLocalizedString("jobs_section", tableName: "MyInfo", comment: "Jobs section title")
}

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    // 팝업 상태 관리
    @State private var selectedSpiritType: SpiritType?
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
        .environmentObject(spiritsRepository)
        .environmentObject(jobsRepository)
        .environmentObject(userRepository)
        
}
