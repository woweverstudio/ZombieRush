import SwiftUI
import GameKit

// MARK: - Game Center Access Point View
struct GameCenterAccessPointView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // 뷰가 윈도우에 붙은 뒤 scene이 생기므로 다음 루프로 넘겨 설정
        DispatchQueue.main.async {
            self.activateAccessPoint(for: view.window?.windowScene)
        }
        
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        // 매 업데이트마다 scene을 확인하고 상태 반영
        activateAccessPoint(for: view.window?.windowScene)
    }
    
    private func activateAccessPoint(for windowScene: UIWindowScene?) {
        guard let scene = windowScene else { return }
        
        let accessPoint = GKAccessPoint.shared
        accessPoint.location = .topTrailing
        accessPoint.showHighlights = false
        accessPoint.isActive = GameKitManager.shared.isAuthenticated
    }
}

// MARK: - Access Point Manager Extension
extension GameCenterAccessPointView {
    /// GKAccessPoint를 비활성화하는 정적 메서드
    static func deactivateAccessPoint() {
        GKAccessPoint.shared.isActive = false
    }
}

// MARK: - Preview
#Preview {
    GameCenterAccessPointView()
        .frame(width: 44, height: 44)
        .preferredColorScheme(.dark)
}
