import SwiftUI

// MARK: - Error Card Component
struct MarketErrorCard: View {
    @Environment(StoreKitManager.self) var storeKitManager
    
    func getStyle(_ error: StoreError) -> CardStyle {
        switch error {
        case .purchaseCancelled, .purchasePending:
            return .cyberpunk
        default:
            return .error
        }
    }
    
    func getCloseButtonColor(_ error: StoreError) -> Color {
        switch error {
        case .purchaseCancelled, .purchasePending:
            return Color.dsTextSecondary
        default:
            return Color.dsError
        }
    }
    var body: some View {
        // 에러 카드 (에러 발생 시에만 표시)
        Group {
            if let error = storeKitManager.currentError {
                Card(style: self.getStyle(error)) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(error.errorDescription)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation{
                                storeKitManager.currentError = nil
                            }                            
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(getCloseButtonColor(error).opacity(0.6))
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
            }
        }
        .ignoresSafeArea(edges: .horizontal)
        .animation(.bouncy, value: storeKitManager.currentError)
        .transition(.slide.combined(with: .opacity))
    }
}
