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
    MyInfoView()
}
