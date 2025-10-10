import SwiftUI

extension PlayerInfoCard {
    static let nemoRescueProgressFormat = NSLocalizedString("nemo_rescue_progress", tableName: "View", comment: "Nemo rescue progress format")
    static let levelPrefix = NSLocalizedString("level_prefix", tableName: "View", comment: "Level prefix")
}

// MARK: - Player Info Card (프로필 + 스탯 통합)
struct PlayerInfoCard: View {
    @Environment(AppRouter.self) var router
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var jobsRepository: SupabaseJobsRepository
    @EnvironmentObject var elementsRepository: SupabaseElementsRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        Button(action: {
            // UI 피드백은 백그라운드에서 처리하여 응답성 향상
            DispatchQueue.global(qos: .userInteractive).async {
                AudioManager.shared.playButtonSound()
                HapticManager.shared.playButtonHaptic()
            }

            // 즉시 액션 실행 (UI 반응성 최우선)
            router.navigate(to: .myInfo)
        }) {
            HStack(spacing: UIConstants.Spacing.x12) {
                VStack(alignment: .leading, spacing: UIConstants.Spacing.x8) {
                    nameInfo
                    levelInfo
                    expInfo
                }
                Spacer()
                elementsInfo
            }
            .padding(UIConstants.Spacing.x16)
            .background(
                CardBackground()
            )
        }
        .buttonStyle(.plain) // 기본 버튼 스타일 제거
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
                Text("\(PlayerInfoCard.levelPrefix)\(levelInfo.currentLevel)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.dsTextPrimary)
            } else {
                Text("-")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    var expInfo: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.x12) {
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
                    
                    Text("(\(percentage)%)")
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
            ForEach(ElementType.allCases, id: \.self) { elementType in
                elementCard(for: elementType)
            }
        }
    }
    
    private func elementCard(for elementType: ElementType) -> some View {
        Card(style: .default) {
            HStack(spacing: UIConstants.Spacing.x8) {
                Image(systemName: elementType.iconName)
                    .foregroundColor(elementType.color)
                    .frame(width: 12)

                Text("\(getElementCount(for: elementType))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func getElementCount(for elementType: ElementType) -> Int {
        guard let elements = elementsRepository.currentElements else { return 0 }

        switch elementType {
        case .fire: return elements.fire
        case .ice: return elements.ice
        case .thunder: return elements.thunder
        case .dark: return elements.dark
        }
    }
}
