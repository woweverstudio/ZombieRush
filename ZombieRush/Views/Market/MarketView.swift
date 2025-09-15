import SwiftUI

// MARK: - Market View
struct MarketView: View {
    @Environment(AppRouter.self) var router

    @State private var selectedCategory: MarketCategory = .skins
    @State private var selectedItem: MarketItem? = nil

    // 샘플 아이템 데이터
    private var skinItems: [MarketItem] {
        [
            .skin(SkinItem(name: "기본 스킨", description: "클래식한 기본 캐릭터", price: 0, iconName: "person.fill", isPurchased: true, healthBonus: 0, ammoBonus: 0, speedBonus: 0)),
            .skin(SkinItem(name: "사이버펑크", description: "네온 빛나는 미래적인 디자인", price: 500, iconName: "sparkles", isPurchased: false, healthBonus: 10, ammoBonus: 5, speedBonus: 2)),
            .skin(SkinItem(name: "네온 나이트", description: "밝은 네온 컬러의 역동적인 스킨", price: 750, iconName: "moon.stars.fill", isPurchased: false, healthBonus: 15, ammoBonus: 8, speedBonus: 3)),
            .skin(SkinItem(name: "골드 에디션", description: "황금빛 광채가 나는 고급 스킨", price: 1000, iconName: "star.fill", isPurchased: false, healthBonus: 20, ammoBonus: 10, speedBonus: 5)),
            .skin(SkinItem(name: "섀도우 헌터", description: "어둠 속에서 빛나는 미스테리한 디자인", price: 600, iconName: "moon.fill", isPurchased: false, healthBonus: 12, ammoBonus: 6, speedBonus: 4)),
            .skin(SkinItem(name: "크롬", description: "광택 나는 크롬 재질의 로보틱 스킨", price: 800, iconName: "circle.grid.3x3.fill", isPurchased: false, healthBonus: 18, ammoBonus: 9, speedBonus: 3))
        ]
    }

    private var weaponItems: [MarketItem] {
        [
            .weapon(WeaponItem(name: "기본 권총", description: "표준 장비 권총", price: 0, iconName: "hand.point.up.fill", isPurchased: true, attackSpeedBonus: 1.0, bulletCountBonus: 0, penetrationBonus: 0)),
            .weapon(WeaponItem(name: "샷건", description: "근거리 강력 화력", price: 300, iconName: "flame.fill", isPurchased: false, attackSpeedBonus: 0.8, bulletCountBonus: 3, penetrationBonus: 1)),
            .weapon(WeaponItem(name: "기관총", description: "연속 발사 고속 무기", price: 500, iconName: "bolt.fill", isPurchased: false, attackSpeedBonus: 1.5, bulletCountBonus: 1, penetrationBonus: 0)),
            .weapon(WeaponItem(name: "레이저 건", description: "고에너지 레이저 무기", price: 800, iconName: "light.beacon.max.fill", isPurchased: false, attackSpeedBonus: 2.0, bulletCountBonus: 0, penetrationBonus: 2)),
            .weapon(WeaponItem(name: "플라즈마 캐논", description: "대형 플라즈마 에너지포", price: 1200, iconName: "waveform.path.ecg", isPurchased: false, attackSpeedBonus: 0.5, bulletCountBonus: 5, penetrationBonus: 3)),
            .weapon(WeaponItem(name: "스마트 건", description: "AI 지원 자동 조준 무기", price: 900, iconName: "target", isPurchased: false, attackSpeedBonus: 1.8, bulletCountBonus: 2, penetrationBonus: 1))
        ]
    }

    private var currentItems: [MarketItem] {
        selectedCategory == .skins ? skinItems : weaponItems
    }

    // MARK: - Sub Views
    private var headerView: some View {
        HStack {
            // 뒤로가기 버튼
            NeonIconButton(icon: "chevron.left", style: .white) {
                router.goBack()
            }

            Spacer()

            // 타이틀
            Text("MARKET")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: Color.cyan, radius: 10, x: 0, y: 0)

            Spacer()

            // 코인 표시 (플레이스홀더)
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                Text("2,500")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var categoryTabsView: some View {
        HStack(spacing: 8) {
            ForEach(MarketCategory.allCases, id: \.self) { category in
                Button(action: {
                    // 오디오/햅틱은 비동기로 처리 (UI 블로킹 방지)
                    DispatchQueue.global(qos: .userInteractive).async {
                        AudioManager.shared.playButtonSound()
                        HapticManager.shared.playButtonHaptic()
                    }

                    // 즉시 액션 실행 (UI 반응성 최우선)
                    selectedCategory = category
                    selectedItem = nil // 카테고리 변경 시 선택 해제
                }) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedCategory == category ? Color.cyan.opacity(0.2) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedCategory == category ? Color.cyan : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
    }

    private var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(currentItems) { item in
                    MarketItemSmallCard(
                        item: item,
                        isSelected: selectedItem?.id == item.id,
                        onTap: {
                            selectedItem = item
                        }
                    )
                }
            }
        }
    }

    private var leftPanelView: some View {
        VStack(spacing: 16) {
            categoryTabsView
            itemsGridView
        }
        .frame(maxWidth: .infinity)
    }

    private var rightPanelView: some View {
        VStack(spacing: 0) {
            if let item = selectedItem {
                MarketItemDetailView(item: item)
            } else {
                // 선택된 아이템이 없을 때의 기본 화면
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "cart.fill.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("아이템을 선택해주세요")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)

                    Text("좌측에서 아이템을 클릭하면\n상세 정보를 확인할 수 있습니다")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            CyberpunkBackground()

            VStack(spacing: 0) {
                headerView

                // 메인 콘텐츠: 좌측 아이템 리스트 + 우측 상세정보
                HStack(spacing: 20) {
                    leftPanelView
                    rightPanelView
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MarketView()
}
