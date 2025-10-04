import SwiftUI

// MARK: - Nemo Jam Badge Component (잔여 네모잼 표시)
struct NemoJamBadge: View {
    @EnvironmentObject var userRepository: SupabaseUserRepository
    @EnvironmentObject var useCaseFactory: UseCaseFactory

    var body: some View {
        HStack(spacing: 4) {
            // 네모 싱글 이미지
            Image("nemo_single")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            // 보유 네모잼 수량 (작게 표시)
            Text("\(userRepository.currentUser?.nemoJam ?? 0)")
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

struct CommonBadge: View {
    let image: Image
    let value: Int
    let size: CGFloat
    let color: Color
    
    var body: some View {
        HStack(spacing: size * 0.2) {
            image                
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
                .frame(width: size * 0.6, height: size * 0.6)
            
            Text("\(value)")
                .font(.system(size: size * 0.7, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, size * 0.6)
        .padding(.vertical, size * 0.4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
