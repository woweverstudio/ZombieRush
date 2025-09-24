import SwiftUI

// MARK: - Player Info Card (프로필 + 스탯 통합)
struct PlayerInfoCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        ZStack {
            CardBackground()

            VStack(spacing: 16) {
                profileInfo

                Divider()
                    .background(Color.dsTextSecondary.opacity(0.3))
                    .frame(maxHeight: .infinity)

                levelInfo
                Divider()
                    .background(Color.dsTextSecondary.opacity(0.3))
                    .frame(maxHeight: .infinity)
                statInfo
            }
            .padding()
        }
    }

    var profileInfo: some View {
        HStack(spacing: 12) {
            // GameKit 프로필 이미지
            if let playerPhoto = gameKitManager.playerPhoto {
                Image(uiImage: playerPhoto)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.fill")
                        .foregroundColor(Color.dsTextPrimary)
                        .font(.system(size: 20))
                }
            }


            VStack(alignment: .leading, spacing: 4) {
                Text(userRepository.currentUser?.nickname ?? "")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("네모나라의 수호자")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }

    var levelInfo: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.dsCoin)
                        .font(.system(size: 16))

                    if let user = userRepository.currentUser {
                        let levelInfo = user.levelInfo
                        Text("Lv. \(levelInfo.currentLevel)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.dsTextPrimary)
                    } else {
                        Text("Lv. --")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }

                // 경험치 바
                VStack(alignment: .leading, spacing: 8) {
                    if let user = userRepository.currentUser {
                        let levelInfo = user.levelInfo
                        let currentLevelExp = levelInfo.currentExp - levelInfo.levelMinExp
                        let requiredExp = levelInfo.expToNextLevel
                        let percentage = Int(levelInfo.progress * 100)

                        Text("네모 구출 \(currentLevelExp)/\(requiredExp)")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 4) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 10)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: 150 * levelInfo.progress, height: 10)
                            }
                            .frame(width: 150)

                            Text("(\(percentage)%)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                        }

                    }
                }
            }
        }
    }

    var statInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let jobs = jobsRepository.currentJobs {
                StatRow(icon: "heart.fill", label: "체력", value: "\(jobs.hp)", color: .red)
                StatRow(icon: "bolt.fill", label: "에너지", value: "\(jobs.energy)", color: .blue)
                StatRow(icon: "shoeprints.fill", label: "이동속도", value: "\(jobs.move)", color: .green)
                StatRow(icon: "bolt.horizontal.fill", label: "공격속도", value: "\(jobs.attackSpeed)", color: .yellow)
                StatRow(icon: "flame.fill", label: "궁극기", value: "궁극기 이름 들어감", color: .orange)
            } else {
                StatRow(icon: "heart.fill", label: "체력", value: "--", color: .red)
                StatRow(icon: "bolt.fill", label: "에너지", value: "--", color: .blue)
                StatRow(icon: "shoeprints.fill", label: "이동속도", value: "--", color: .green)
                StatRow(icon: "bolt.horizontal.fill", label: "공격속도", value: "--", color: .yellow)
                StatRow(icon: "flame.fill", label: "궁극기", value: "궁극기 이름 들어감", color: .orange)
            }
        }
    }
}
