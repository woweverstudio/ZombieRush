import SwiftUI

extension PlayerInfoCard {
    static let playerTitle = NSLocalizedString("player_title", tableName: "Main", comment: "Player title")    
    static let dashPlaceholder = NSLocalizedString("dash_placeholder", tableName: "Main", comment: "Dash placeholder")
    static let nemoRescueProgressFormat = NSLocalizedString("nemo_rescue_progress", tableName: "Main", comment: "Nemo rescue progress format")
    static let percentageFormat = NSLocalizedString("percentage_format", tableName: "Main", comment: "Percentage format")
}

// MARK: - Player Info Card (프로필 + 스탯 통합)
struct PlayerInfoCard: View {
    @Environment(GameKitManager.self) var gameKitManager
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        ZStack {
            CardBackground()

            VStack(spacing: 12) {
                profileInfo

                levelInfo
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
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 34, height: 34)

                    Image(systemName: "person.fill")
                        .foregroundColor(Color.dsTextPrimary)
                        .font(.system(size: 18))
                }
            }


            VStack(alignment: .leading, spacing: 4) {
                Text(userRepository.currentUser?.nickname ?? "")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(verbatim: PlayerInfoCard.playerTitle)
                    .font(.system(size: 10, design: .monospaced))
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
                        Text("Lv. \(PlayerInfoCard.dashPlaceholder)")
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

                        Text(verbatim: String(format: PlayerInfoCard.nemoRescueProgressFormat, currentLevelExp, requiredExp))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 8) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: 150 * levelInfo.progress, height: 8)
                            }
                            .frame(width: 150)

                            Text(verbatim: String(format: PlayerInfoCard.percentageFormat, percentage))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                        }

                    }
                }
            }
        }
    }
}
