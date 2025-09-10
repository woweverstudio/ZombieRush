import SwiftUI

struct LoginPromptCard: View {
    @Environment(AppRouter.self) var router

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.white.opacity(0.5))

            VStack{
                Text(NSLocalizedString("LOGIN_PROMPT_PLAYER_CARD", comment: "Login prompt for Player Card"))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
    }
}

#Preview {
    LoginPromptCard()
        .background(Color.black)
}
