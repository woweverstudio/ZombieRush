import SwiftUI

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
                .scaledToFill()
                .ignoresSafeArea()

            HStack {
                previousButton
                Spacer()
                nextButton
            }

            VStack(spacing: 0) {
                Spacer()

                // 스토리 텍스트
                VStack(spacing: 20) {
                    Text(getStoryText(for: currentStoryIndex))
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.5))
                )
                
            }
        }
    }

    private func getStoryText(for index: Int) -> String {
        switch index {
        case 1: return TextConstants.Story.story1
        case 2: return TextConstants.Story.story2
        case 3: return TextConstants.Story.story3
        case 4: return TextConstants.Story.story4
        case 5: return TextConstants.Story.story5
        default: return ""
        }
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
        NeonIconButton(
            icon: "chevron.left",
            style: .magenta,
            size: 24
        ) {
            withAnimation(.easeInOut) {
                currentStoryIndex -= 1
            }
        }
        .opacity(currentStoryIndex == 1 ? 0 : 1)
    }
    
    private var nextButton: some View {
        NeonIconButton(
            icon: "chevron.right",
            style: .magenta,
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
