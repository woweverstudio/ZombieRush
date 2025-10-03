import SwiftUI

extension MyInfoView {
    static let myInfoTitle = NSLocalizedString("my_info_title", tableName: "MyInfo", comment: "My info title")
}

// MARK: - 내 정보 View
struct MyInfoView: View {
    @Environment(AppRouter.self) var router

    var body: some View {
        ZStack {
            // 사이버펑크 배경
            Background()

            VStack(spacing: 0) {
                headerView
                Spacer()
            }
        }
    }
}

// MARK: - Sub Views
extension MyInfoView {
    private var headerView: some View {
        Header(
            title: MyInfoView.myInfoTitle,
            badges: [],
            onBack: {
                router.quitToMain()
            }
        )
    }
}





// MARK: - Preview
#Preview {
    MyInfoView()
}
