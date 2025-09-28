import SwiftUI

extension StoryView {
    static let story1 = NSLocalizedString("story1", tableName: "Intro", comment: "Story 1 text")
    static let story2 = NSLocalizedString("story2", tableName: "Intro", comment: "Story 2 text")
    static let story3 = NSLocalizedString("story3", tableName: "Intro", comment: "Story 3 text")
    static let story4 = NSLocalizedString("story4", tableName: "Intro", comment: "Story 4 text")
    static let story5 = NSLocalizedString("story5", tableName: "Intro", comment: "Story 5 text")
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
            .padding(.horizontal, 30)

            VStack(spacing: 0) {
                Spacer()

                // 스토리 텍스트
                VStack(spacing: 20) {
                    Text(getStoryText(for: currentStoryIndex))
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(Color.dsTextPrimary)
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
                        .fill(Color.dsSurface)
                )
                
            }
        }
    }

    private func getStoryText(for index: Int) -> String {
        switch index {
        case 1: return StoryView.story1
        case 2: return StoryView.story2
        case 3: return StoryView.story3
        case 4: return StoryView.story4
        case 5: return StoryView.story5
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
