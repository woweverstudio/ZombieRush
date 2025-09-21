import SwiftUI

// MARK: - Job Card (TabView로 해금된 job만 표시)
struct JobCard: View {
    @Environment(JobsStateManager.self) var jobsStateManager

    // 이전/다음 탭으로 이동 (해금된 직업만)
    private func previousTab() {
        withAnimation {
            let unlockedJobs = jobsStateManager.currentJobs.unlockedJobs
            if let currentIndex = unlockedJobs.firstIndex(of: jobsStateManager.selectedJobType) {
                let prevIndex = currentIndex > 0 ? currentIndex - 1 : unlockedJobs.count - 1
                jobsStateManager.currentJobs.selectedJob = unlockedJobs[prevIndex].rawValue
            }
        }
    }

    private func nextTab() {
        withAnimation {
            let unlockedJobs = jobsStateManager.currentJobs.unlockedJobs
            if let currentIndex = unlockedJobs.firstIndex(of: jobsStateManager.selectedJobType) {
                let nextIndex = currentIndex < unlockedJobs.count - 1 ? currentIndex + 1 : 0
                jobsStateManager.currentJobs.selectedJob = unlockedJobs[nextIndex].rawValue
            }
        }
    }

    var body: some View {
        @Bindable var jobState = jobsStateManager
        ZStack {
            CardBackground()

            VStack {
                // 진척 인디케이터
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.dsCoin)
                        .font(.system(size: 10))

                    Text("직업 \(jobsStateManager.currentJobs.unlockedJobs.count)/\(JobType.allCases.count) 해금됨")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top)

                // TabView로 해금된 job 표시 (indicator 제거)
                TabView(selection: $jobState.currentJobs.selectedJob) {
                    ForEach(jobsStateManager.currentJobs.unlockedJobs, id: \.self) { jobType in
                        JobDetailView()
                            .tag(jobType.rawValue)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }

            // 네비게이션 버튼들 (해금된 직업이 2개 이상일 때만 표시)
            if jobsStateManager.currentJobs.unlockedJobs.count > 1 {
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
    }
}

// MARK: - 개별 Job 상세 정보 View
struct JobDetailView: View {
    @Environment(JobsStateManager.self) var jobsStateManager

    var body: some View {
        VStack(spacing: 8) {
            Image("sample")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            

            // Job 이름 (간단하게 표시)
            Text(jobsStateManager.currentJobName)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color.dsTextPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
}
