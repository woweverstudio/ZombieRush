import SwiftUI

extension PlayerInfoCard {
    static let dashPlaceholder = NSLocalizedString("dash_placeholder", tableName: "Main", comment: "Dash placeholder")
    static let nemoRescueProgressFormat = NSLocalizedString("nemo_rescue_progress", tableName: "Main", comment: "Nemo rescue progress format")
    static let percentageFormat = NSLocalizedString("percentage_format", tableName: "Main", comment: "Percentage format")
}

// MARK: - Player Info Card (프로필 + 스탯 통합)
struct PlayerInfoCard: View {
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var spiritsRepository: SupabaseSpiritsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                nameInfo
                levelInfo
                expInfo
            }
            Spacer()
            elementsInfo
        }
        .padding(16)
        .background(
            CardBackground()
        )
    }
    
    var nameInfo: some View {
        Text(userRepository.currentUser?.nickname ?? "")
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundColor(.dsTextSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }


    var levelInfo: some View {
        Group {
            if let user = userRepository.currentUser {
                let levelInfo = user.levelInfo
                Text("Lv. \(levelInfo.currentLevel)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
            } else {
                Text("Lv. \(PlayerInfoCard.dashPlaceholder)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    var expInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let user = userRepository.currentUser {
                let levelInfo = user.levelInfo
                let currentLevelExp = levelInfo.currentExp - levelInfo.levelMinExp
                let requiredExp = levelInfo.expToNextLevel
                let percentage = Int(levelInfo.progress * 100)
                Text(verbatim: String(format: PlayerInfoCard.nemoRescueProgressFormat, currentLevelExp, requiredExp))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: 100 * levelInfo.progress, height: 8)
                    }
                    
                    Text(verbatim: String(format: PlayerInfoCard.percentageFormat, percentage))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.dsSuccess)
                }
            }
        }
    }
    
    var elementsInfo: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            ForEach(SpiritType.allCases, id: \.self) { spiritType in
                elementCard(for: spiritType)
            }
        }
    }
    
    private func elementCard(for spiritType: SpiritType) -> some View {
        Card(style: .default) {
            HStack(spacing: 8) {
                Image(systemName: spiritType.iconName)
                    .foregroundColor(spiritType.color)
                    .frame(width: 12)

                Text("\(getSpiritCount(for: spiritType))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
