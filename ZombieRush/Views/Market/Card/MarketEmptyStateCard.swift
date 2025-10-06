import SwiftUI

// MARK: - Market Empty State Card
struct MarketEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "wifi.slash")
                    .font(.system(size: 32))
                    .foregroundColor(.red.opacity(0.7))
            }

            VStack(spacing: 8) {
                Text("인터넷 연결이 필요합니다")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.dsTextPrimary)
                    .multilineTextAlignment(.center)

                Text("인터넷에 연결하거나\nGame Center에 로그인한 후\n재접속해주세요")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.dsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .frame(minHeight: 300)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    MarketEmptyStateCard()
        .background(Color.black)
}
