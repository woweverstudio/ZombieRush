import SwiftUI

// MARK: - Job Card (TabView로 해금된 job만 표시)
struct JobCard: View {
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    @State private var selectedJob: String = "novice"

    // 이전/다음 탭으로 이동 (해금된 직업만)
    private func previousTab() {
        guard let jobs = jobsRepository.currentJobs else { return }
        withAnimation {
            let unlockedJobs = jobs.unlockedJobs
            if let currentIndex = unlockedJobs.firstIndex(where: { $0.rawValue == selectedJob }) {
                let prevIndex = currentIndex > 0 ? currentIndex - 1 : unlockedJobs.count - 1
                let newJobType = unlockedJobs[prevIndex]
                selectedJob = newJobType.rawValue
                // UseCase 호출로 실제 DB 업데이트
                Task {
                    let request = SelectJobRequest(jobType: newJobType)
                    _ = try? await useCaseFactory.selectJob.execute(request)
                }
            }
        }
    }

    private func nextTab() {
        guard let jobs = jobsRepository.currentJobs else { return }
        withAnimation {
            let unlockedJobs = jobs.unlockedJobs
            if let currentIndex = unlockedJobs.firstIndex(where: { $0.rawValue == selectedJob }) {
                let nextIndex = currentIndex < unlockedJobs.count - 1 ? currentIndex + 1 : 0
                let newJobType = unlockedJobs[nextIndex]
                selectedJob = newJobType.rawValue
                // UseCase 호출로 실제 DB 업데이트
                Task {
                    let request = SelectJobRequest(jobType: newJobType)
                    _ = try? await useCaseFactory.selectJob.execute(request)
                }
            }
        }
    }

    var body: some View {
        ZStack {
            CardBackground()

            VStack {
                // 진척 인디케이터
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.dsCoin)
                        .font(.system(size: 10))

                    if let jobs = jobsRepository.currentJobs {
                        Text("직업 \(jobs.unlockedJobs.count)/\(JobType.allCases.count) 해금됨")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("직업 0/\(JobType.allCases.count) 해금됨")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top)

                // TabView로 해금된 job 표시 (indicator 제거)
                if let jobs = jobsRepository.currentJobs {
                    TabView(selection: $selectedJob) {
                        ForEach(jobs.unlockedJobs, id: \.self) { jobType in
                            JobDetailView(jobType: jobType)
                                .tag(jobType.rawValue)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
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
        .onAppear {
            // 초기 선택된 job 설정
            if let jobs = jobsRepository.currentJobs {
                selectedJob = jobs.selectedJob
            }
        }
        .onChange(of: jobsRepository.currentJobs?.selectedJob) { _, newValue in
            if let newValue = newValue {
                selectedJob = newValue
            }
        }
    }
}

// MARK: - 개별 Job 상세 정보 View
struct JobDetailView: View {
    let jobType: JobType

    var body: some View {
        VStack(spacing: 8) {
            Image("sample")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)


            // Job 이름 (간단하게 표시)
            Text(jobType.displayName)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
}
