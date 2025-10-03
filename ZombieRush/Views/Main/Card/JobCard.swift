import SwiftUI

extension JobCard {
    static let jobsUnlockedFormat = NSLocalizedString("jobs_unlocked_format", tableName: "Main", comment: "Jobs unlocked format")
    static let dashPlaceholder = NSLocalizedString("dash_placeholder", tableName: "Main", comment: "Dash placeholder")
}

// MARK: - Job Card (TabView로 해금된 job만 표시)
struct JobCard: View {
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory
    
    @State private var selectedJob: JobType = .novice

    // 이전/다음 탭으로 이동 (해금된 직업만)
    private func previousTab() {
        guard let jobs = jobsRepository.currentJobs else { return }
        
        let unlockedJobs = jobs.unlockedJobs

        withAnimation {
            if let currentIndex = unlockedJobs.firstIndex(where: { $0 == selectedJob }) {
                let prevIndex = currentIndex > 0 ? currentIndex - 1 : unlockedJobs.count - 1
                let newJobType = unlockedJobs[prevIndex]
                
                selectedJob = newJobType
            }
        }
    }

    private func nextTab() {
        guard let jobs = jobsRepository.currentJobs else { return }
        
        let unlockedJobs = jobs.unlockedJobs
        
        withAnimation {
            if let currentIndex = unlockedJobs.firstIndex(where: { $0 == selectedJob }) {
                let nextIndex = currentIndex < unlockedJobs.count - 1 ? currentIndex + 1 : 0
                let newJobType = unlockedJobs[nextIndex]
                
                selectedJob = newJobType
            }
        }
    }

    var body: some View {
        ZStack {
            // TabView로 해금된 job 표시 (indicator 제거)
            if let jobs = jobsRepository.currentJobs {
                TabView(selection: $selectedJob) {
                    ForEach(jobs.unlockedJobs, id: \.rawValue) { jobType in
                        JobDetailView(jobType: jobType)
                            .tag(jobType)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 180)
            }
        
            // 네비게이션 버튼들 (해금된 직업이 2개 이상일 때만 표시)
            if let jobs = jobsRepository.currentJobs, jobs.unlockedJobs.count > 1 {
                HStack {
                    Button(action: previousTab) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(20)
                            .clipShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    // 우측 chevron 버튼
                    Button(action: nextTab) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(20)
                            .clipShape(Rectangle())
                    }
                }
            }
        }
        .background (
            CardBackground()
        )
        .onAppear {
            guard let jobs = jobsRepository.currentJobs else { return }
            selectedJob = jobs.selectedJobType
        }
    }
    
    func JobDetailView(jobType: JobType) -> some View {
        HStack {
            Spacer()
            Image(jobType.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)

            VStack(alignment: .leading) {
                // Job 이름 (간단하게 표시)
                Text(verbatim: jobType.localizedDisplayName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
                    .padding(8)
                    .multilineTextAlignment(.center)
                
                ForEach(StatType.allCases, id: \.self) { statType in
                    HStack {
                        Image(systemName: statType.iconName)
                            .foregroundColor(statType.color)
                            .font(.system(size: 10))
                            .frame(width: 20)
                        
                        Text(statType.localizedDisplayName)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .minimumScaleFactor(0.8)
                            .frame(width: 80, alignment: .leading)

                        Text("\(JobStats.getStat(job: self.selectedJob, stat: statType))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                    }
                    .padding(.vertical, 3)
                }
            }
        }
        .padding(8)
    }
}
