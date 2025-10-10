import SwiftUI

// MARK: - Map View (맵 선택)
struct MapView: View {
    @Environment(AppRouter.self) var router
    @Environment(MapManager.self) var mapManager

    @State private var currentIndex: Int = 0

    var body: some View {
        @Bindable var bMapManager = mapManager
        ZStack {
            // 사이버펑크 배경
            Background()
            
            VStack {
                headerView

                VStack(spacing: UIConstants.Spacing.x24) {
                    // 맵 캐러셀
                    MapCarousel(
                        items: mapManager.maps.map { MapCard(map: $0) },
                        currentIndex: $currentIndex
                    )

                    // 페이지 인디케이터
                    PageIndicator(
                        count: mapManager.maps.count,
                        currentIndex: $currentIndex
                    )
                }

                Spacer()

                // CTA: 게임 시작 버튼
                PrimaryButton(title: "게임시작", fullWidth: true) {

                }
                .ctaButtonSpacing()
            }
            .pagePadding()
            .onChange(of: currentIndex) {
                let selectedMap = mapManager.maps[currentIndex]
                bMapManager.selectedMap = selectedMap
            }
            .onAppear {
                if let selectedMap = bMapManager.selectedMap,
                   let index = mapManager.maps.firstIndex(where: { $0.id == selectedMap.id }) {
                    currentIndex = index
                }
            }
        }
    }


    // MARK: - Subviews
    private var headerView: some View {
        Header(
            title: "Map",
            onBack: {
                router.goBack()
            }
        )
    }
}
