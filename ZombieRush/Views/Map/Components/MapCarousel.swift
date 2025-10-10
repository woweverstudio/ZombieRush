import SwiftUI

// MARK: - Map Carousel Component
struct MapCarousel<Content: View>: View {
    let items: [Content]
    @Binding var currentIndex: Int
    let autoScrollEnabled: Bool

    @State private var scrollPosition: Int?

    init(items: [Content], currentIndex: Binding<Int>, autoScrollEnabled: Bool = false) {
        self.items = items
        self._currentIndex = currentIndex
        self.autoScrollEnabled = autoScrollEnabled
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: UIConstants.Spacing.x16) {
                ForEach(0..<items.count, id: \.self) { index in
                    items[index]
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, UIConstants.Spacing.x16)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrollPosition)
        .frame(maxHeight: .infinity)
        .onChange(of: scrollPosition) {
            if let position = scrollPosition {
                currentIndex = position
            }
        }
        .onChange(of: currentIndex) {
            scrollPosition = currentIndex
        }
        .onAppear {
            scrollPosition = currentIndex
            if autoScrollEnabled {
                startAutoScroll()
            }
        }
    }

    // MARK: - Auto Scroll (선택사항)
    func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.spring(duration: 0.6)) {
                    currentIndex = (currentIndex + 1) % items.count
                }
            }
        }
    }
}

// MARK: - Page Indicator Component
struct PageIndicator: View {
    let count: Int
    @Binding var currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? Color.cyan : Color.white.opacity(0.3))
                    .frame(width: currentIndex == index ? 12 : 8, height: currentIndex == index ? 12 : 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            currentIndex = index
                        }
                    }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        @State var currentIndex: Int = 1

        MapCarousel(
            items: [
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.red.gradient)
                    .frame(height: 400)
                    .overlay(
                        Text("Fire")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    ),
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.blue.gradient)
                    .frame(height: 400)
                    .overlay(
                        Text("Water")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    ),
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.green.gradient)
                    .frame(height: 400)
                    .overlay(
                        Text("Earth")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    )
            ],
            currentIndex: $currentIndex
        )

        PageIndicator(count: 3, currentIndex: $currentIndex)

        Text("Current Index: \(currentIndex)")
            .font(.headline)
            .foregroundColor(.white)
    }
    .padding()
    .background(Color.black)
}
