import SwiftUI

extension StoryView {

}

// MARK: - Story View
struct StoryView: View {
    @Environment(AppRouter.self) var router

    @State private var currentStoryIndex = 1
    private let totalStories = 5

    var body: some View {
        ZStack {
            // 스토리 배경 이미지
            getCurrentStoryImage()
                .resizable()
                .scaledToFit()
                

            HStack {
                previousButton
                Spacer()
                nextButton
            }
            .padding(.horizontal, UIConstants.Spacing.x24)

            VStack(spacing: 0) {
                Spacer()

                // 스토리 텍스트
                VStack(spacing: UIConstants.Spacing.x24) {
                    Text(getStoryText(for: currentStoryIndex))
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(Color.dsTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(UIConstants.Spacing.x8)
                        .padding(.horizontal, UIConstants.Spacing.x16)
                        .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                }
                .padding(.vertical, UIConstants.Spacing.x24)
                .padding(.horizontal, UIConstants.Spacing.x24)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.dsSurface)
                )
                
            }
        }
    }

    private func getStoryText(for index: Int) -> String {
        "TODO: 스토리 재구성 필요"
    }

    private func getCurrentStoryImage() -> Image {
        let imageName = "story\(currentStoryIndex)"
        
        if currentStoryIndex <= 5 {
            return Image(imageName)
        } else {
            return Image("story1")
        }
        
    }
    
    private var previousButton: some View {
        IconButton(
            iconName: "chevron.left",
            style: .white,
            size: 24
        ) {
            withAnimation(.easeInOut) {
                currentStoryIndex -= 1
            }
        }
        .opacity(currentStoryIndex == 1 ? 0 : 1)
    }
    
    private var nextButton: some View {
        IconButton(
            iconName: "chevron.right",
            style: .white,
            size: 24
        ) {
            withAnimation(.easeInOut) {
                currentStoryIndex += 1
            }

            if currentStoryIndex == totalStories + 1 {
                UserDefaults.standard.set(true, forKey: "hasSeenStory")
                UserDefaults.standard.synchronize()

                // 메인 화면으로 이동
                router.quitToMain()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StoryView()
        .environment(AppRouter())
}
