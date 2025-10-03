import SwiftUI

// MARK: - Nemo Fruit Badge Component (잔여 네모열매 표시)
struct NemoFruitBadge: View {
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        HStack(spacing: 4) {
            // 네모 싱글 이미지
            Image("nemo_single")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            // 보유 네모열매 수량 (작게 표시)
            Text("\(userRepository.currentUser?.nemoFruit ?? 0)")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.cyan)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
